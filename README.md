# Rail

Offline-first iOS app with the timetables of **Cercanías Málaga**, the Renfe commuter rail network in Málaga. Native Swift and SwiftUI, no third-party dependencies.

Built for the [ACoding Hackathon 2026](https://acoding.academy/hackaton26/) by Apple Coding Academy.

## Why

We, Juan Salguero ([@jsalgueroibarrola](https://github.com/jsalgueroibarrola)) and Desirée Rodríguez ([@Sukiarts](https://github.com/Sukiarts)), both ride Cercanías, and the official app doesn't fit how we use it or what we expect from it:

- **No offline mode.** At a station without coverage you can no longer see the timetable.
- **Station screens often don't work**, so there's no fallback there either.
- **When Renfe's servers are slow or down, the timetable disappears too**, even though it hardly ever changes apart from delays or problems on the line.
- **It isn't a native app**, and it has other UX problems.

Rail downloads the network and the timetable once, stores them on the device and serves every screen from that local copy, so timetables are always available. Live train positions and service alerts are shown on top whenever there's a connection.

## Scope

Because of the hackathon's time limit, and because the app started from our own everyday use, the scope is only **Cercanías Málaga**.

## Data

Thanks to Renfe for publishing the open datasets on [data.renfe.com](https://data.renfe.com) that made this app possible.

Origen de los datos: Renfe Operadora.

Rail is an independent project and is not affiliated with, sponsored by or endorsed by Renfe.

## API

The app doesn't read Renfe's datasets directly. It uses an API that Juan Salguero put together as a workaround to make the data easier for the app to consume. That API isn't part of this repository; how it works will be explained soon.

## Running it

Open `Rail/Rail.xcodeproj` in Xcode 27 and run the `Rail` scheme. The app requires iOS 26 or later.

## License

The code is under the [PolyForm Noncommercial License 1.0.0](LICENSE.md): you can use, study, modify and share it for any noncommercial purpose, but not for commercial use. Renfe's data keeps its own terms of use.
