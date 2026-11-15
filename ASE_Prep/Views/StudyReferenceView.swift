import SwiftUI

struct StudyReferenceView: View {
    @EnvironmentObject var store: StudyStore
    @State private var selectedSection: ReferenceTab = .vacuum

    enum ReferenceTab: String, CaseIterable, Identifiable {
        case vacuum = "Vacuum Gauge"
        case leakdown = "Leak-Down"
        case specs = "Shop Specs"
        case strategies = "Exam Strategy"
        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    switch selectedSection {
                    case .vacuum:
                        vacuumReferenceSection
                    case .leakdown:
                        leakDownReferenceSection
                    case .specs:
                        shopSpecsSection
                    case .strategies:
                        examStrategySection
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .safeAreaInset(edge: .top) {
                Picker("Reference Section", selection: $selectedSection) {
                    ForEach(ReferenceTab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .liquidGlassFloatingBar(cornerRadius: 18)
                .padding(.horizontal, 14)
                .padding(.top, 4)
            }
            .navigationTitle("Shop Reference Guide")
        }
    }

    // MARK: - Vacuum Gauge Section

    private var vacuumReferenceSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            infoBanner(
                title: "Sea-Level Intake Manifold Vacuum",
                subtitle: "Note: Normal idle vacuum drops ~1 in. Hg for every 1,000 ft of elevation above sea level.",
                icon: "gauge.with.dots.needle.67percent",
                color: .blue
            )

            referenceRow(
                badge: "17–21 in. Hg (Steady)",
                badgeColor: .green,
                title: "Normal Healthy Engine",
                detail: "Needle holds steady between 17 and 21 in. Hg at warm idle. Snap-throttle drops to ~2 in. Hg on open, spikes to 23–25 in. Hg on snap-close."
            )

            referenceRow(
                badge: "10–14 in. Hg (Steady Low)",
                badgeColor: .orange,
                title: "Late Valve/Ignition Timing or Intake Leak",
                detail: "A low but steady needle across all cylinders indicates retarded camshaft timing (jumped tooth), late ignition timing, or a large intake manifold/plenum vacuum leak."
            )

            referenceRow(
                badge: "Rhythmic Drop (2–4 in. Hg)",
                badgeColor: .red,
                title: "Burned, Leaking, or Sticking Valve",
                detail: "Needle drops sharply by 2–4 in. Hg on a regular beat every time that cylinder's intake event occurs."
            )

            referenceRow(
                badge: "Rapid Flutter (14–19 in. Hg)",
                badgeColor: .purple,
                title: "Worn Valve Guides or Weak Valve Springs",
                detail: "Fast, erratic needle vibration at idle or increased RPM indicates valve bounce/float from weak springs or excessive stem-to-guide clearance."
            )

            referenceRow(
                badge: "Gradual Drop to 0 at 2,500 RPM",
                badgeColor: .red,
                title: "Restricted Exhaust / Plugged Catalyst",
                detail: "Starts normal at idle, but when held at 2,500 RPM, exhaust backpressure builds and causes intake manifold vacuum to steadily sink toward 0 in. Hg."
            )
        }
    }

    // MARK: - Leak-Down Section

    private var leakDownReferenceSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            infoBanner(
                title: "Cylinder Leakage (Leak-Down) Test",
                subtitle: "Perform with piston at TDC on Compression Stroke. Healthy cylinders show <10–15% leakage.",
                icon: "wind",
                color: .indigo
            )

            referenceRow(
                badge: "Throttle Body / Intake Duct",
                badgeColor: .blue,
                title: "Leaking Intake Valve",
                detail: "Air hissing out of the open throttle body means compressed air is escaping past a burned, bent, carbon-held, or overly tight (insufficient lash) intake valve."
            )

            referenceRow(
                badge: "Tailpipe / Exhaust Manifold",
                badgeColor: .orange,
                title: "Leaking Exhaust Valve",
                detail: "Air heard at the tailpipe or exhaust manifold port indicates a burned, warped, or improperly seated exhaust valve."
            )

            referenceRow(
                badge: "Oil Filler Cap / Dipstick Tube",
                badgeColor: .purple,
                title: "Worn Piston Rings or Holed Piston",
                detail: "Air escaping into the crankcase indicates excessive leakage past the piston compression rings, a scored cylinder wall, or a cracked piston crown."
            )

            referenceRow(
                badge: "Radiator Neck Bubbles",
                badgeColor: .red,
                title: "Blown Head Gasket or Cracked Casting",
                detail: "Air bubbles rising in the radiator neck or degas bottle confirm combustion chamber air is entering the cooling water jacket."
            )

            referenceRow(
                badge: "Adjacent Spark Plug Hole",
                badgeColor: .red,
                title: "Head Gasket Breach Between Cylinders",
                detail: "Air blowing out of the neighboring cylinder's spark plug hole indicates the head gasket fire-ring web has failed between the two adjacent cylinders."
            )
        }
    }

    // MARK: - Shop Specs Section

    private var shopSpecsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            infoBanner(
                title: "A1–A9 High-Yield Formulas & Shop Specs",
                subtitle: "Critical measurements and diagnostic rules tested across the ASE A-Series exams.",
                icon: "ruler.fill",
                color: .teal
            )

            referenceRow(
                badge: "A1 Engine",
                badgeColor: .blue,
                title: "Bore Taper, Out-of-Round & Plastigage",
                detail: "• Bore Taper = Top Dia. − Bottom Dia. (thrust axis)\n• Out-of-Round = Thrust Axis Dia. − Pin Axis Dia. (same depth)\n• Plastigage: Wider crushed wax strip = TIGHTER oil clearance (never rotate crank!)\n• Solid Bucket Shim Formula: New Shim = Old Shim + (Measured Lash − Spec Lash)"
            )

            referenceRow(
                badge: "A2 / A3 Drivetrain",
                badgeColor: .indigo,
                title: "Stall Speed, Standpipe ATF & Gear Backlash",
                detail: "• Low Stall RPM in all ranges = Torque converter stator 1-way clutch freewheeling\n• High Stall RPM (flare) = Slipping clutch pack or low line pressure\n• Sealed ATF Standpipe: Check with engine idling in Park at specified scan-tool ATF temp\n• Ring Gear Face Contact (top of tooth) = Move pinion deeper toward ring centerline"
            )

            referenceRow(
                badge: "A4 / A5 Chassis",
                badgeColor: .red,
                title: "Alignment Pull Rules & Brake Specifications",
                detail: "• Alignment Pull Rule: Vehicle pulls toward MOST positive camber and LEAST positive caster\n• Load-Carrying Ball Joint: Support under control arm near ball joint to unload spring\n• Duo-Servo Drum Brakes: Shorter primary shoe faces FRONT; longer secondary shoe faces REAR\n• Rotor MIN THICK: Minimum thickness AFTER machining (replace if below spec)"
            )

            referenceRow(
                badge: "A6 Electrical",
                badgeColor: .orange,
                title: "Ohm's Law, Voltage Drop & CAN Bus Termination",
                detail: "• Ohm's Law: E = I × R | Parallel Equal Resistors: R_total = R / N\n• Max Cranking Positive Cable Drop: ≤ 0.5V | Ground Drop: ≤ 0.2V\n• Parasitic Draw Limit: Typically < 35–50 mA after modules sleep (check via fuse mV drop)\n• High-Speed CAN Bus (DLC Pins 6 & 14, battery off): 60 Ω normal; 120 Ω = 1 open terminator"
            )

            referenceRow(
                badge: "A7 / A8 / A9",
                badgeColor: .purple,
                title: "HVAC Oil, Fuel Trims, Lambda & Diesel DEF",
                detail: "• Hybrid/EV Electric A/C Compressor: Requires non-conductive POE oil (never standard PAG)\n• High +Fuel Trim at Idle only (drops at 2,500 RPM) = Intake manifold vacuum leak\n• Wideband Lambda (λ): λ = 1.00 Stoich | λ > 1.00 Lean | λ < 1.00 Rich\n• Diesel DEF (ISO 22241): 32.5% urea / 67.5% deionized water (checked via refractometer)"
            )
        }
    }

    // MARK: - Exam Strategy Section

    private var examStrategySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            infoBanner(
                title: "ASE \(store.selectedExam.rawValue) Test-Taking Strategies",
                subtitle: "\(store.selectedExam.scoredExamQuestions) Scored Questions + 10 Unscored Research Questions = \(store.selectedExam.totalExamQuestions) Questions in \(store.selectedExam.examTimeLimitMinutes) Minutes.",
                icon: "lightbulb.fill",
                color: .orange
            )

            referenceRow(
                badge: "Archetype 1",
                badgeColor: .blue,
                title: "Technician A / Technician B Strategy",
                detail: "Evaluate Technician A completely on their own first (True or False). Then evaluate Technician B completely on their own. Watch out for statements that use the right measurement name with the wrong tool (e.g., using an outside micrometer to measure an internal bore)."
            )

            referenceRow(
                badge: "Archetype 2",
                badgeColor: .red,
                title: "Negative Qualifiers (EXCEPT / LEAST Likely)",
                detail: "Mentally mark each option (A, B, C, D) as True or False. Three options will be true causes or valid steps; pick the lone option that is false or causes the opposite effect."
            )

            referenceRow(
                badge: "Archetype 3",
                badgeColor: .green,
                title: "Verify Before Teardown",
                detail: "When asked what a technician should do FIRST, ASE always favors fast, non-invasive verification steps (checking oil level, connecting a mechanical test gauge, removing the serpentine belt to isolate noise) over immediate component replacement."
            )
        }
    }

    // MARK: - Helpers

    private func infoBanner(title: String, subtitle: String, icon: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func referenceRow(badge: String, badgeColor: Color, title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(badge)
                .font(.caption.weight(.bold))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(badgeColor.opacity(0.15))
                .foregroundStyle(badgeColor)
                .clipShape(Capsule())

            Text(title)
                .font(.subheadline.weight(.bold))

            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .liquidGlassCard(cornerRadius: 14)
    }
}
