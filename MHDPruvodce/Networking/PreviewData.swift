import Foundation

enum PreviewData {
    static let stops: [Stop] = [
        Stop(id: "U953Z1", name: "Náměstí Míru", city: "Praha", latitude: 50.0754, longitude: 14.4378, lines: ["A", "4", "22"]),
        Stop(id: "U1108Z1", name: "Hlavní nádraží", city: "Praha", latitude: 50.0831, longitude: 14.4356, lines: ["C", "9", "26"]),
        Stop(id: "U953Z2", name: "I. P. Pavlova", city: "Praha", latitude: 50.0740, longitude: 14.4322, lines: ["C", "4", "10"]),
        Stop(id: "U100Z1", name: "Anděl", city: "Praha", latitude: 50.0701, longitude: 14.4035, lines: ["B", "4", "7", "9"]),
        Stop(id: "U200Z1", name: "Muzeum", city: "Praha", latitude: 50.0792, longitude: 14.4310, lines: ["A", "C", "11"]),
        Stop(id: "U300Z1", name: "Brno hlavní nádraží", city: "Brno", latitude: 49.1900, longitude: 16.6133, lines: ["R1", "EC", "1"]),
        Stop(id: "U400Z1", name: "Náměstí Svobody", city: "Brno", latitude: 49.1953, longitude: 16.6083, lines: ["1", "2", "4"]),
    ]

    static let segments: [Segment] = [
        Segment(
            id: "seg1",
            lineNumber: "A",
            lineType: .metro,
            departureStop: stops[0],
            arrivalStop: stops[4],
            departureTime: Date().addingTimeInterval(300),
            arrivalTime: Date().addingTimeInterval(600),
            intermediateStops: [
                StopTime(id: "st1", stop: stops[2], scheduledTime: Date().addingTimeInterval(420), actualTime: nil, platform: nil)
            ],
            platform: "1",
            headsign: "Dejvická"
        ),
        Segment(
            id: "seg2",
            lineNumber: "C",
            lineType: .metro,
            departureStop: stops[4],
            arrivalStop: stops[1],
            departureTime: Date().addingTimeInterval(660),
            arrivalTime: Date().addingTimeInterval(900),
            intermediateStops: [],
            platform: "2",
            headsign: "Letňany"
        ),
    ]

    static let connections: [Connection] = [
        Connection(
            id: "conn1",
            departureTime: Date().addingTimeInterval(300),
            arrivalTime: Date().addingTimeInterval(2700),
            duration: 40,
            transfers: 1,
            segments: segments,
            isRealtime: true,
            delay: 0
        ),
        Connection(
            id: "conn2",
            departureTime: Date().addingTimeInterval(900),
            arrivalTime: Date().addingTimeInterval(3300),
            duration: 40,
            transfers: 0,
            segments: [
                Segment(
                    id: "seg3",
                    lineNumber: "22",
                    lineType: .tram,
                    departureStop: stops[0],
                    arrivalStop: stops[1],
                    departureTime: Date().addingTimeInterval(900),
                    arrivalTime: Date().addingTimeInterval(3300),
                    intermediateStops: [],
                    platform: nil,
                    headsign: "Bílá Hora"
                )
            ],
            isRealtime: true,
            delay: 3
        ),
        Connection(
            id: "conn3",
            departureTime: Date().addingTimeInterval(1800),
            arrivalTime: Date().addingTimeInterval(5400),
            duration: 60,
            transfers: 2,
            segments: segments,
            isRealtime: false,
            delay: nil
        ),
    ]
}
