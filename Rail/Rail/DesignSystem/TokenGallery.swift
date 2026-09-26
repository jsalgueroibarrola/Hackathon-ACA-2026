#if DEBUG
    import SwiftUI

    private struct TokenGallery: View {
        private let colorGroups: [(String, [(String, Color)])] = [
            (
                "Background",
                [
                    ("bgPrimary", .bgPrimary), ("bgSecondary", .bgSecondary),
                    ("bgTertiary", .bgTertiary),
                    ("bgElevated", .bgElevated), ("bgInverse", .bgInverse),
                    ("bgScrim", .bgScrim),
                ]
            ),
            (
                "Text",
                [
                    ("textPrimary", .textPrimary),
                    ("textSecondary", .textSecondary),
                    ("textTertiary", .textTertiary),
                    ("textInverse", .textInverse),
                    ("textOnBrand", .textOnBrand), ("textLink", .textLink),
                    ("textDisabled", .textDisabled),
                ]
            ),
            (
                "Border",
                [
                    ("borderDefault", .borderDefault),
                    ("borderSubtle", .borderSubtle),
                    ("borderStrong", .borderStrong),
                    ("borderFocus", .borderFocus),
                ]
            ),
            (
                "Brand",
                [
                    ("brandPrimary", .brandPrimary),
                    ("brandPrimaryHover", .brandPrimaryHover),
                    ("brandPrimaryPressed", .brandPrimaryPressed),
                    ("brandPrimarySubtle", .brandPrimarySubtle),
                    ("brandOnPrimary", .brandOnPrimary),
                    ("brandCercanias", .brandCercanias),
                    ("brandTintFill", .brandTintFill),
                ]
            ),
            (
                "Fill",
                [("fillTertiary", .fillTertiary)]
            ),
            (
                "Glass",
                [
                    ("glassFillTinted", .glassFillTinted),
                    ("glassText", .glassText),
                ]
            ),
            (
                "Status",
                [
                    ("statusSuccess", .statusSuccess),
                    ("statusSuccessBg", .statusSuccessBg),
                    ("statusSuccessText", .statusSuccessText),
                    ("statusWarning", .statusWarning),
                    ("statusWarningBg", .statusWarningBg),
                    ("statusWarningText", .statusWarningText),
                    ("statusError", .statusError),
                    ("statusErrorBg", .statusErrorBg),
                    ("statusErrorText", .statusErrorText),
                    ("statusInfo", .statusInfo),
                    ("statusInfoBg", .statusInfoBg),
                    ("statusInfoText", .statusInfoText),
                ]
            ),
            (
                "Transit",
                [
                    ("transitOnTime", .transitOnTime),
                    ("transitOnTimeBg", .transitOnTimeBg),
                    ("transitOnTimeText", .transitOnTimeText),
                    ("transitDelayed", .transitDelayed),
                    ("transitDelayedBg", .transitDelayedBg),
                    ("transitDelayedText", .transitDelayedText),
                    ("transitCancelled", .transitCancelled),
                    ("transitCancelledBg", .transitCancelledBg),
                    ("transitCancelledText", .transitCancelledText),
                ]
            ),
            (
                "Interactive",
                [
                    ("interactiveTabbarActive", .interactiveTabbarActive),
                    ("interactiveTabbarInactive", .interactiveTabbarInactive),
                    ("interactiveSeparator", .interactiveSeparator),
                    ("interactiveIcon", .interactiveIcon),
                    ("interactiveIconSubtle", .interactiveIconSubtle),
                    ("interactivePressedOverlay", .interactivePressedOverlay),
                    ("interactiveFavorite", .interactiveFavorite),
                    ("interactiveFavoriteBg", .interactiveFavoriteBg),
                    ("interactiveFavoriteText", .interactiveFavoriteText),
                    ("interactiveFavoritePressed", .interactiveFavoritePressed),
                ]
            ),
        ]

        private let spacings: [(String, CGFloat)] = [
            ("none", Spacing.none), ("xxs", Spacing.xxs), ("xs", Spacing.xs),
            ("sm", Spacing.sm),
            ("md", Spacing.md), ("lg", Spacing.lg), ("xl", Spacing.xl),
            ("xxl", Spacing.xxl),
            ("xxxxl", Spacing.xxxxl),
        ]

        private let radii: [(String, CGFloat)] = [
            ("sm", Radius.sm), ("md", Radius.md),
            ("lg", Radius.lg), ("xl", Radius.xl),
        ]

        private let fonts: [(String, Font)] = [
            ("largeTitle", .largeTitle), ("title", .title), ("title2", .title2),
            ("title2Emphasized", .title2Emphasized),
            ("title3", .title3),
            ("title3Emphasized", .title3Emphasized),
            ("headline", .headline), ("body", .body),
            ("bodyEmphasized", .bodyEmphasized),
            ("bodyMedium", .bodyMedium),
            ("callout", .callout), ("subheadline", .subheadline),
            ("subheadlineEmphasized", .subheadlineEmphasized),
            ("footnote", .footnote), ("caption", .caption),
            ("captionEmphasized", .captionEmphasized),
            ("caption2", .caption2), ("timeDeparture", .timeDeparture),
            ("timeDepartureLarge", .timeDepartureLarge),
        ]

        private let lines: [(String, String, String, String)] = [
            ("C1", "DA291C", "FDF3F2", "62100A"),
            ("C2", "0057A8", "EEF5FC", "002446"),
        ]

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xxl) {
                    ForEach(colorGroups, id: \.0) { group in
                        section(group.0) {
                            LazyVGrid(
                                columns: [
                                    GridItem(
                                        .adaptive(minimum: 96),
                                        spacing: Spacing.sm
                                    )
                                ],
                                spacing: Spacing.sm
                            ) {
                                ForEach(group.1, id: \.0) { swatch in
                                    VStack(spacing: Spacing.xs) {
                                        RoundedRectangle(
                                            cornerRadius: Radius.sm,
                                            style: .continuous
                                        )
                                        .fill(swatch.1)
                                        .stroke(
                                            .borderSubtle,
                                            lineWidth: Border.hairline
                                        )
                                        .frame(height: 40)
                                        Text(swatch.0).font(.caption2)
                                            .lineLimit(1).minimumScaleFactor(
                                                0.6
                                            )
                                    }
                                }
                            }
                        }
                    }
                    section("Líneas (API → LineTint)") {
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            ForEach(lines, id: \.0) { line in
                                let tint = LineTint(base: Color(hex: line.1))
                                HStack(spacing: Spacing.md) {
                                    LineBadge(line.0, color: tint.base)
                                    LineBadge(
                                        line.0,
                                        color: tint.base,
                                        scale: .large
                                    )
                                    swatchPair(
                                        "subtle",
                                        derived: tint.subtle,
                                        figma: Color(hex: line.2),
                                        figmaDark: Color(hex: line.3)
                                    )
                                }
                            }
                        }
                    }
                    section("Spacing") {
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            ForEach(spacings, id: \.0) { item in
                                HStack(spacing: Spacing.sm) {
                                    Text(item.0).font(.caption.monospaced())
                                        .frame(width: 64, alignment: .leading)
                                    Rectangle().fill(.brandPrimary).frame(
                                        width: max(item.1, 1),
                                        height: 12
                                    )
                                    Text(item.1, format: .number).font(
                                        .caption2
                                    ).foregroundStyle(.textSecondary)
                                }
                            }
                        }
                    }
                    section("Radius") {
                        HStack(spacing: Spacing.md) {
                            ForEach(radii, id: \.0) { item in
                                VStack(spacing: Spacing.xs) {
                                    RoundedRectangle(
                                        cornerRadius: item.1,
                                        style: .continuous
                                    )
                                    .fill(.brandPrimarySubtle)
                                    .stroke(
                                        .brandPrimary,
                                        lineWidth: Border.hairline
                                    )
                                    .frame(width: 56, height: 40)
                                    Text(item.0).font(.caption2)
                                }
                            }
                            VStack(spacing: Spacing.xs) {
                                Capsule().fill(.brandPrimarySubtle).stroke(
                                    .brandPrimary,
                                    lineWidth: Border.hairline
                                ).frame(width: 56, height: 40)
                                Text("full").font(.caption2)
                            }
                        }
                    }
                    section("Typography") {
                        VStack(alignment: .leading, spacing: Spacing.sm) {
                            ForEach(fonts, id: \.0) { item in
                                HStack(
                                    alignment: .firstTextBaseline,
                                    spacing: Spacing.md
                                ) {
                                    Text(item.0).font(.caption2.monospaced())
                                        .foregroundStyle(.textSecondary).frame(
                                            width: 140,
                                            alignment: .leading
                                        )
                                    Text("14:06 Fuengirola").font(item.1)
                                }
                            }
                        }
                    }
                    section("Elevation") {
                        HStack(spacing: Spacing.xl) {
                            elevationCard("none", .none)
                            elevationCard("card", .card)
                            elevationCard("sheet", .sheet)
                            elevationCard("floating", .floating)
                        }
                        .padding(Spacing.xl)
                        .frame(maxWidth: .infinity)
                        .background(
                            .bgSecondary,
                            in: .rect(
                                cornerRadius: Radius.lg,
                                style: .continuous
                            )
                        )
                    }
                    section("Ilustraciones") {
                        HStack(alignment: .bottom, spacing: Spacing.xl) {
                            ForEach(EmptyStateIllustration.Kind.allCases, id: \.self) { kind in
                                EmptyStateIllustration(kind)
                                    .frame(height: kind.height / 2)
                            }
                        }
                        .padding(Spacing.md)
                        .frame(maxWidth: .infinity)
                        .background(
                            .bgSecondary,
                            in: .rect(
                                cornerRadius: Radius.lg,
                                style: .continuous
                            )
                        )
                        TrainIllustration()
                            .frame(height: 53)
                            .padding(Spacing.md)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .background(
                                .bgSecondary,
                                in: .rect(
                                    cornerRadius: Radius.lg,
                                    style: .continuous
                                )
                            )
                        ZStack(alignment: .topLeading) {
                            HomeHeroImage()
                            RailLogo()
                                .frame(height: Size.touchMin)
                                .padding(Spacing.md)
                        }
                        .frame(height: 160)
                        .clipShape(
                            .rect(cornerRadius: Radius.lg, style: .continuous)
                        )
                    }
                }
                .padding(ScreenLayout.margin)
            }
            .background(.bgPrimary)
            .foregroundStyle(.textPrimary)
        }

        private func section(
            _ title: String,
            @ViewBuilder content: () -> some View
        ) -> some View {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(title).font(.headline)
                content()
            }
        }

        private func swatchPair(
            _ label: String,
            derived: Color,
            figma: Color,
            figmaDark: Color
        ) -> some View {
            HStack(spacing: Spacing.xs) {
                RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                    .fill(derived).frame(width: 40, height: 28)
                RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                    .fill(figma).frame(width: 40, height: 28)
                RoundedRectangle(cornerRadius: Radius.sm, style: .continuous)
                    .fill(figmaDark).frame(width: 40, height: 28)
                Text(label).font(.caption2).foregroundStyle(.textSecondary)
            }
        }

        private func elevationCard(_ title: String, _ level: Elevation)
            -> some View
        {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Málaga Centro").font(.subheadlineEmphasized)
                Text("C-1 · 14:06").font(.footnote).foregroundStyle(
                    .textSecondary
                )
                Text(title).font(.caption2).foregroundStyle(.textTertiary)
            }
            .padding(Spacing.lg)
            .background(
                .bgElevated,
                in: .rect(cornerRadius: Radius.lg, style: .continuous)
            )
            .elevation(level)
        }
    }

    #Preview("Light") {
        TokenGallery()
            .preferredColorScheme(.light)
    }

    #Preview("Dark") {
        TokenGallery()
            .preferredColorScheme(.dark)
    }
#endif
