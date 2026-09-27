import SwiftUI

extension EnvironmentValues {
    @Entry var connectivity: any ConnectivityService = DisabledConnectivityService()
}
