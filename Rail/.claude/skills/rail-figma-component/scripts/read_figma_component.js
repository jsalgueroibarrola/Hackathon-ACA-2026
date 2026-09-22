const NODE_IDS = ["40:71"];
const VARIABLE_NAMES = [];

const collections = await figma.variables.getLocalVariableCollectionsAsync();

const hex = (c) => {
  const h = (v) => Math.round(v * 255).toString(16).padStart(2, "0").toUpperCase();
  return h(c.r) + h(c.g) + h(c.b) + (c.a !== undefined && c.a < 1 ? h(c.a) : "");
};

const resolve = async (value, modeName) => {
  if (value && value.type === "VARIABLE_ALIAS") {
    const target = await figma.variables.getVariableByIdAsync(value.id);
    const coll = collections.find((c) => c.id === target.variableCollectionId);
    const mode = coll.modes.find((m) => m.name === modeName) || coll.modes[0];
    return `${target.name} → ${await resolve(target.valuesByMode[mode.modeId], modeName)}`;
  }
  if (value && typeof value === "object" && "r" in value) return hex(value);
  return String(value);
};

const describeVariable = async (variable) => {
  const coll = collections.find((c) => c.id === variable.variableCollectionId);
  const modes = {};
  for (const m of coll.modes) modes[m.name] = await resolve(variable.valuesByMode[m.modeId], m.name);
  return { name: variable.name, collection: coll.name, iOS: variable.codeSyntax?.iOS ?? null, modes };
};

const aliasIds = (value, into) => {
  if (!value || typeof value !== "object") return;
  if (value.type === "VARIABLE_ALIAS") into.add(value.id);
  else Object.values(value).forEach((v) => aliasIds(v, into));
};

const components = [];
const boundIds = new Set();

for (const id of NODE_IDS) {
  const node = await figma.getNodeByIdAsync(id);
  if (!node) {
    components.push({ id, missing: true });
    continue;
  }
  [node, ...("findAll" in node ? node.findAll(() => true) : [])].forEach((n) => aliasIds(n.boundVariables, boundIds));

  let section = node.parent;
  while (section && section.type !== "SECTION" && section.type !== "PAGE") section = section.parent;
  let page = section;
  while (page && page.type !== "PAGE") page = page.parent;

  const docTexts = section && section.type === "SECTION"
    ? section.children
        .filter((c) => c.id !== node.id && "findAll" in c)
        .flatMap((c) => c.findAll((n) => n.type === "TEXT").map((n) => n.characters))
    : [];

  components.push({
    id,
    name: node.name,
    type: node.type,
    description: "description" in node ? node.description : null,
    variants: "children" in node ? node.children.map((c) => ({ id: c.id, name: c.name, width: c.width, height: c.height })) : [],
    section: section && section.type === "SECTION" ? { id: section.id, name: section.name } : null,
    page: page ? { id: page.id, name: page.name } : null,
    docTexts,
  });
}

const allVariables = await figma.variables.getLocalVariablesAsync();
const wanted = VARIABLE_NAMES.length > 0
  ? allVariables.filter((v) => VARIABLE_NAMES.includes(v.name))
  : allVariables.filter((v) => boundIds.has(v.id));

const variables = [];
for (const v of wanted) variables.push(await describeVariable(v));
const missing = VARIABLE_NAMES.filter((name) => !allVariables.some((v) => v.name === name));

return { components, variables, missing };
