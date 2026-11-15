import Foundation
import SwiftUI

// MARK: - Official ASE A-Series Exam Catalog (A1–A9)

enum ASEExamID: String, Codable, CaseIterable, Identifiable {
    case a1 = "A1"
    case a2 = "A2"
    case a3 = "A3"
    case a4 = "A4"
    case a5 = "A5"
    case a6 = "A6"
    case a7 = "A7"
    case a8 = "A8"
    case a9 = "A9"

    var id: String { rawValue }
    var code: String { rawValue }

    var title: String {
        switch self {
        case .a1: return "Engine Repair"
        case .a2: return "Automatic Transmission & Transaxle"
        case .a3: return "Manual Drive Train & Axles"
        case .a4: return "Suspension & Steering"
        case .a5: return "Brakes"
        case .a6: return "Electrical & Electronic Systems"
        case .a7: return "Heating & Air Conditioning"
        case .a8: return "Engine Performance"
        case .a9: return "Light Vehicle Diesel Engines"
        }
    }

    var shortSubtitle: String {
        switch self {
        case .a1: return "Mechanical Diagnosis, Cylinder Head, Block, Lube & Cooling"
        case .a2: return "Hydraulics, Torque Converters, Planetary Gears & Solenoids"
        case .a3: return "Clutches, Manual Transmissions, Shafts, Differentials & 4WD"
        case .a4: return "Steering Gears, EPS, Struts, 4-Wheel Alignment & Tires"
        case .a5: return "Hydraulics, Disc/Drum, Power Boosters, ABS/ESC & Regen"
        case .a6: return "Circuits, Batteries, Starting, Charging, CAN Bus & Accessories"
        case .a7: return "Refrigeration Cycle, Compressors, Heating, Blend Doors & Auto A/C"
        case .a8: return "Ignition, Fuel Trim, GDI, Turbo/EGR, O2/Catalyst & OBD-II"
        case .a9: return "High-Pressure Common Rail, Glow Plugs, Turbo & DPF/SCR"
        }
    }

    var fullTitle: String {
        "ASE \(rawValue): \(title)"
    }

    var iconName: String {
        switch self {
        case .a1: return "wrench.and.screwdriver.fill"
        case .a2: return "gearshape.2.fill"
        case .a3: return "arrow.triangle.branch"
        case .a4: return "steeringwheel"
        case .a5: return "circle.dotted.circle.fill"
        case .a6: return "bolt.car.fill"
        case .a7: return "snowflake"
        case .a8: return "waveform.path.ecg"
        case .a9: return "fuelpump.fill"
        }
    }

    var themeColor: Color {
        switch self {
        case .a1: return .blue
        case .a2: return .indigo
        case .a3: return .teal
        case .a4: return .cyan
        case .a5: return .red
        case .a6: return .orange
        case .a7: return .mint
        case .a8: return .purple
        case .a9: return .green
        }
    }

    /// Official total questions on the Prometric exam (scored + 10 unscored research questions)
    var totalExamQuestions: Int {
        switch self {
        case .a3, .a4: return 45
        default: return 55
        }
    }

    /// Official scored questions on the Prometric exam
    var scoredExamQuestions: Int {
        totalExamQuestions - 10
    }

    /// Official time limit in minutes at Prometric
    var examTimeLimitMinutes: Int {
        switch self {
        case .a3, .a4: return 60
        case .a6: return 90
        default: return 75
        }
    }

    /// StoreKit 2 Non-Consumable Product Identifier for individual exam unlock ($9.99)
    var singleExamProductID: String {
        "com.treanorcorp.aseprep.exam.\(rawValue.lowercased())"
    }

    static let masterBundleProductID = "com.treanorcorp.aseprep.bundle.master_a1_a9"
    static let masterUpgradeProductID = "com.treanorcorp.aseprep.bundle.master_upgrade"

    /// JSON resource filename in Bundle (e.g. "questions_a2.json", with fallback to "questions.json" for A1)
    var resourceFileNames: [String] {
        if self == .a1 {
            return ["questions_a1", "questions"]
        }
        return ["questions_\(rawValue.lowercased())"]
    }

    struct DomainSpec {
        let domain: ASEDomain
        let title: String
        let weightPercentage: Int
        let examQuestionCount: Int
        let iconName: String
    }

    var domainSpecs: [DomainSpec] {
        switch self {
        case .a1:
            return [
                DomainSpec(domain: .sectionA, title: "General Engine Diagnosis", weightPercentage: 35, examQuestionCount: 19, iconName: "gauge.with.dots.needle.67percent"),
                DomainSpec(domain: .sectionB, title: "Cylinder Head & Valve Train", weightPercentage: 20, examQuestionCount: 11, iconName: "cylinder.split.1x2.fill"),
                DomainSpec(domain: .sectionC, title: "Engine Block Diagnosis & Repair", weightPercentage: 15, examQuestionCount: 9, iconName: "gearshape.2.fill"),
                DomainSpec(domain: .sectionD, title: "Lubrication & Cooling Systems", weightPercentage: 15, examQuestionCount: 8, iconName: "drop.degreesign.fill"),
                DomainSpec(domain: .sectionE, title: "Fuel, Electrical, Ignition, Air & Exhaust", weightPercentage: 15, examQuestionCount: 8, iconName: "bolt.car.fill")
            ]
        case .a2:
            return [
                DomainSpec(domain: .sectionA, title: "General Transmission & Transaxle Diagnosis", weightPercentage: 50, examQuestionCount: 27, iconName: "waveform.path.ecg.rectangle.fill"),
                DomainSpec(domain: .sectionB, title: "In-Vehicle Transmission Maintenance & Repair", weightPercentage: 26, examQuestionCount: 14, iconName: "wrench.adjustable.fill"),
                DomainSpec(domain: .sectionC, title: "Off-Vehicle Transmission & Transaxle Repair", weightPercentage: 24, examQuestionCount: 14, iconName: "gearshape.2.fill")
            ]
        case .a3:
            return [
                DomainSpec(domain: .sectionA, title: "Clutch Diagnosis & Repair", weightPercentage: 20, examQuestionCount: 9, iconName: "circle.circle.fill"),
                DomainSpec(domain: .sectionB, title: "Manual Transmission & Transaxle", weightPercentage: 25, examQuestionCount: 11, iconName: "gearshape.fill"),
                DomainSpec(domain: .sectionC, title: "Drive Shaft, Half Shaft & CV Joints", weightPercentage: 25, examQuestionCount: 11, iconName: "gyroscope"),
                DomainSpec(domain: .sectionD, title: "Drive Axle, Differential & 4WD/AWD", weightPercentage: 30, examQuestionCount: 14, iconName: "arrow.triangle.branch")
            ]
        case .a4:
            return [
                DomainSpec(domain: .sectionA, title: "Steering Systems Diagnosis & Repair", weightPercentage: 30, examQuestionCount: 14, iconName: "steeringwheel"),
                DomainSpec(domain: .sectionB, title: "Suspension Systems Diagnosis & Repair", weightPercentage: 33, examQuestionCount: 15, iconName: "springs" == "" ? "arrow.up.and.down.circle.fill" : "arrow.up.and.down.circle.fill"),
                DomainSpec(domain: .sectionC, title: "Wheel Alignment Diagnosis, Adjustment & Repair", weightPercentage: 25, examQuestionCount: 11, iconName: "angle"),
                DomainSpec(domain: .sectionD, title: "Wheel & Tire Diagnosis and Service", weightPercentage: 12, examQuestionCount: 5, iconName: "circle.dashed.inset.filled")
            ]
        case .a5:
            return [
                DomainSpec(domain: .sectionA, title: "Hydraulic, Power Assist & Parking Brake Systems", weightPercentage: 29, examQuestionCount: 16, iconName: "drop.fill"),
                DomainSpec(domain: .sectionB, title: "Drum Brake Diagnosis & Repair", weightPercentage: 11, examQuestionCount: 6, iconName: "circle.lefthalf.filled"),
                DomainSpec(domain: .sectionC, title: "Disc Brake Diagnosis & Repair", weightPercentage: 27, examQuestionCount: 15, iconName: "circle.dotted.circle.fill"),
                DomainSpec(domain: .sectionD, title: "Power Assist Units Diagnosis & Repair", weightPercentage: 11, examQuestionCount: 6, iconName: "gauge.with.needle.fill"),
                DomainSpec(domain: .sectionE, title: "Electronic Brake Control (ABS, TCS, ESC) & Regen", weightPercentage: 22, examQuestionCount: 12, iconName: "sensor.tag.radiowaves.forward.fill")
            ]
        case .a6:
            return [
                DomainSpec(domain: .sectionA, title: "General Electrical & Circuit Diagnosis", weightPercentage: 32, examQuestionCount: 18, iconName: "waveform.path.ecg"),
                DomainSpec(domain: .sectionB, title: "Battery & Starting Systems Diagnosis", weightPercentage: 20, examQuestionCount: 11, iconName: "minus.plus.batteryblock.fill"),
                DomainSpec(domain: .sectionC, title: "Charging System Diagnosis & Repair", weightPercentage: 12, examQuestionCount: 7, iconName: "bolt.circle.fill"),
                DomainSpec(domain: .sectionD, title: "Lighting, Instrument Cluster & Driver Info", weightPercentage: 18, examQuestionCount: 10, iconName: "light.beacon.max.fill"),
                DomainSpec(domain: .sectionE, title: "Body Electrical, CAN Network & Accessories", weightPercentage: 18, examQuestionCount: 9, iconName: "network")
            ]
        case .a7:
            return [
                DomainSpec(domain: .sectionA, title: "A/C System Service, Diagnosis & Repair", weightPercentage: 30, examQuestionCount: 17, iconName: "snowflake"),
                DomainSpec(domain: .sectionB, title: "Refrigeration System Components", weightPercentage: 26, examQuestionCount: 14, iconName: "fanblades.fill"),
                DomainSpec(domain: .sectionC, title: "Heating & Engine Cooling Systems", weightPercentage: 18, examQuestionCount: 10, iconName: "thermometer.high"),
                DomainSpec(domain: .sectionD, title: "Operating Systems & Automatic Climate Controls", weightPercentage: 26, examQuestionCount: 14, iconName: "slider.horizontal.3")
            ]
        case .a8:
            return [
                DomainSpec(domain: .sectionA, title: "General Engine & OBD-II Diagnosis", weightPercentage: 22, examQuestionCount: 12, iconName: "gauge.with.dots.needle.67percent"),
                DomainSpec(domain: .sectionB, title: "Computerized Engine Controls Diagnosis", weightPercentage: 24, examQuestionCount: 13, iconName: "cpu.fill"),
                DomainSpec(domain: .sectionC, title: "Ignition System Diagnosis & Repair", weightPercentage: 16, examQuestionCount: 9, iconName: "bolt.fill"),
                DomainSpec(domain: .sectionD, title: "Fuel, Air Induction & Exhaust Systems", weightPercentage: 20, examQuestionCount: 11, iconName: "fuelpump.fill"),
                DomainSpec(domain: .sectionE, title: "Emissions Control Systems (EGR, EVAP, Cat)", weightPercentage: 18, examQuestionCount: 10, iconName: "smoke.fill")
            ]
        case .a9:
            return [
                DomainSpec(domain: .sectionA, title: "General Light Diesel Diagnosis", weightPercentage: 24, examQuestionCount: 13, iconName: "gauge.with.dots.needle.67percent"),
                DomainSpec(domain: .sectionB, title: "Cylinder Head, Glow Plugs & Valvetrain", weightPercentage: 16, examQuestionCount: 9, iconName: "cylinder.split.1x2.fill"),
                DomainSpec(domain: .sectionC, title: "Diesel Engine Block, Pistons & Liners", weightPercentage: 14, examQuestionCount: 8, iconName: "gearshape.2.fill"),
                DomainSpec(domain: .sectionD, title: "Lubrication, Cooling & Oil Coolers", weightPercentage: 16, examQuestionCount: 9, iconName: "drop.degreesign.fill"),
                DomainSpec(domain: .sectionE, title: "HPCR Fuel Injection, Turbo, EGR & DPF/SCR", weightPercentage: 30, examQuestionCount: 16, iconName: "fuelpump.fill")
            ]
        }
    }

    var activeDomains: [ASEDomain] {
        domainSpecs.map { $0.domain }
    }

    func spec(for domain: ASEDomain) -> DomainSpec {
        if let match = domainSpecs.first(where: { $0.domain == domain }) {
            return match
        }
        return DomainSpec(
            domain: domain,
            title: domain.title,
            weightPercentage: domain.examWeightPercentage,
            examQuestionCount: domain.examQuestionCount,
            iconName: domain.iconName
        )
    }
}

// MARK: - Content Area Domain Identifier (Sections A–G)

enum ASEDomain: String, Codable, CaseIterable, Identifiable {
    case sectionA = "A"
    case sectionB = "B"
    case sectionC = "C"
    case sectionD = "D"
    case sectionE = "E"
    case sectionF = "F"
    case sectionG = "G"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sectionA:
            return "General Engine Diagnosis"
        case .sectionB:
            return "Cylinder Head & Valve Train"
        case .sectionC:
            return "Engine Block Diagnosis & Repair"
        case .sectionD:
            return "Lubrication & Cooling Systems"
        case .sectionE:
            return "Fuel, Electrical, Ignition, Air & Exhaust"
        case .sectionF:
            return "Electronic Controls & Sensors"
        case .sectionG:
            return "Advanced Systems & Diagnostics"
        }
    }

    var shortLabel: String {
        "Section \(rawValue)"
    }

    var examWeightPercentage: Int {
        switch self {
        case .sectionA: return 35
        case .sectionB: return 20
        case .sectionC: return 15
        case .sectionD: return 15
        case .sectionE: return 15
        case .sectionF: return 10
        case .sectionG: return 10
        }
    }

    var examQuestionCount: Int {
        switch self {
        case .sectionA: return 19
        case .sectionB: return 11
        case .sectionC: return 9
        case .sectionD: return 8
        case .sectionE: return 8
        case .sectionF: return 5
        case .sectionG: return 5
        }
    }

    var iconName: String {
        switch self {
        case .sectionA: return "gauge.with.dots.needle.67percent"
        case .sectionB: return "cylinder.split.1x2.fill"
        case .sectionC: return "gearshape.2.fill"
        case .sectionD: return "drop.degreesign.fill"
        case .sectionE: return "bolt.car.fill"
        case .sectionF: return "cpu.fill"
        case .sectionG: return "sensor.tag.radiowaves.forward.fill"
        }
    }

    var themeColor: Color {
        switch self {
        case .sectionA: return .blue
        case .sectionB: return .indigo
        case .sectionC: return .orange
        case .sectionD: return .teal
        case .sectionE: return .purple
        case .sectionF: return .cyan
        case .sectionG: return .red
        }
    }
}

struct Question: Identifiable, Codable, Hashable {
    let id: Int
    let domain: ASEDomain
    let archetype: String
    let question: String
    let options: [String]
    let correctIndex: Int
    let rationale: String

    var optionLetters: [String] {
        ["A", "B", "C", "D"]
    }
}

struct ExamSessionRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    let modeTitle: String
    let totalQuestions: Int
    let correctCount: Int
    let durationSeconds: Int
    let domainBreakdown: [String: DomainScore]

    struct DomainScore: Codable {
        var total: Int
        var correct: Int

        var percentage: Double {
            guard total > 0 else { return 0 }
            return (Double(correct) / Double(total)) * 100.0
        }
    }

    var percentageScore: Double {
        guard totalQuestions > 0 else { return 0 }
        return (Double(correctCount) / Double(totalQuestions)) * 100.0
    }

    var passed: Bool {
        percentageScore >= 70.0
    }
}

// MARK: - Built-in Diagnostic Sampler Questions for A2–A9 (Used Until Full 250-Q JSONs Are Added)

extension ASEExamID {
    static func builtInSamplerQuestions(for exam: ASEExamID) -> [Question] {
        switch exam {
        case .a1:
            return []
        case .a2:
            return [
                Question(
                    id: 1,
                    domain: .sectionA,
                    archetype: "MOST Likely",
                    question: "A vehicle with an electronically controlled 6-speed automatic transmission exhibits harsh, erratic upshifts and sets a transmission fluid temperature (TFT) sensor circuit high-voltage code. Live scan tool data displays a TFT reading of -40°F (-40°C) regardless of actual transmission temperature. What is the MOST likely cause?",
                    options: [
                        "A short to ground in the TFT thermistor signal wire",
                        "An open circuit in the TFT sensor harness or connector",
                        "Low automatic transmission fluid level in the oil pan",
                        "A stuck-closed torque converter clutch (TCC) PWM solenoid"
                    ],
                    correctIndex: 1,
                    rationale: "Transmission Fluid Temperature (TFT) sensors are Negative Temperature Coefficient (NTC) thermistors whose resistance increases as temperature drops. An open circuit creates infinite resistance, which the TCM interprets as extreme cold (-40°F) and commands default high line pressure (causing harsh shifts)."
                ),
                Question(
                    id: 2,
                    domain: .sectionA,
                    archetype: "Technician A / B",
                    question: "During a stall test on an automatic transmission, the engine RPM reaches 1,350 RPM in both Drive and Reverse, which is 650 RPM BELOW the factory stall specification of 2,000–2,200 RPM. Engine power and tune-up parameters are verified normal. Technician A says the torque converter stator one-way clutch may be slipping. Technician B says forward clutch pack slippage would cause a lower-than-normal stall speed. Who is correct?",
                    options: [
                        "Technician A only",
                        "Technician B only",
                        "Both Technician A and Technician B",
                        "Neither Technician A nor Technician B"
                    ],
                    correctIndex: 0,
                    rationale: "Technician A is correct: if the torque converter stator one-way roller/sprag clutch freewheels in both directions, oil returning from the turbine hits the back of the impeller blades and drags engine stall RPM down by 500–800 RPM in all gears. Technician B is incorrect because a slipping clutch pack causes stall RPM to exceed specification (runaway flare)."
                ),
                Question(
                    id: 3,
                    domain: .sectionB,
                    archetype: "Direct Diagnostic",
                    question: "When checking automatic transmission fluid (ATF) level on a modern sealed transaxle equipped with an overflow standpipe integrated into the bottom drain plug (and no dipstick), under what conditions must the level check plug be removed?",
                    options: [
                        "With the engine OFF, transmission cold, and vehicle raised on a front bumper jack",
                        "With the engine idling in Park, vehicle level, and ATF temperature within the specified scan-tool window (typically 95°F–113°F)",
                        "With the engine revved to 2,500 RPM in Drive and ATF temperature above 210°F",
                        "Immediately after draining the pan while the torque converter is empty"
                    ],
                    correctIndex: 1,
                    rationale: "Standpipe-level transmissions must be checked with the engine running at idle (so the pump fills the torque converter and cooler circuits) and at the exact specified warm ATF temperature range read via scan tool, because ATF expands significantly as it heats up."
                ),
                Question(
                    id: 4,
                    domain: .sectionC,
                    archetype: "EXCEPT Qualifier",
                    question: "While overhauling an automatic transmission on the bench, a technician performs an air-pressure test on the clutch apply passages in the case with regulated shop air (~30–40 psi). All of the following indicate a healthy clutch pack circuit EXCEPT:",
                    options: [
                        "A dull thud as the piston strokes and compresses the clutch pack",
                        "The clutch plates locking solidly so they cannot be turned by hand while air is applied",
                        "The piston returning briskly when air pressure is removed",
                        "Loud continuous air hissing past the piston lip seals with no piston movement"
                    ],
                    correctIndex: 3,
                    rationale: "Loud air hissing without piston movement indicates a torn/rolled piston lip seal, missing check ball, or cracked piston housing. A good clutch pack applies with a firm thud, holds pressure, and releases cleanly when air is removed."
                ),
                Question(
                    id: 5,
                    domain: .sectionC,
                    archetype: "Direct Diagnostic",
                    question: "When inspecting a planetary gearset during off-vehicle transmission disassembly, how should the technician check pinion gear thrust washer wear?",
                    options: [
                        "Measure pinion gear axial end play between the pinion gear and carrier housing using a feeler gauge",
                        "Heat the planetary carrier to 400°F with a propane torch",
                        "Check ring gear outside diameter with an outside micrometer",
                        "Soak the carrier assembly in automatic transmission fluid for 24 hours"
                    ],
                    correctIndex: 0,
                    rationale: "Planetary pinion axial clearance (end play) is measured by sliding a feeler gauge between each pinion gear thrust washer and the planetary carrier body; typical specification is 0.009 to 0.024 in. (0.23–0.60 mm)."
                )
            ]
        case .a3:
            return [
                Question(
                    id: 1,
                    domain: .sectionA,
                    archetype: "MOST Likely",
                    question: "A customer with a manual transmission complains that the transmission grinds harshly when shifting into Reverse from a stop, and the 1st-to-2nd shift is stiff even with the clutch pedal pushed all the way to the floorboard. Pumping the clutch pedal several times slightly improves disengagement. What is the MOST likely cause?",
                    options: [
                        "Air in the hydraulic clutch actuator circuit or internal master/slave cylinder bypass leakage",
                        "Worn brass synchronizerblocking rings on 3rd and 4th gears",
                        "Oil contamination on the clutch friction disc linings",
                        "Excessive rear differential ring-and-pinion backlash"
                    ],
                    correctIndex: 0,
                    rationale: "Grinding into Reverse (an unsynchronized gear) combined with hard shifting into 1st/2nd indicates incomplete clutch release (the input shaft continues spinning with the pedal depressed). Air or hydraulic leakage in the clutch master/slave cylinder reduces release bearing travel."
                ),
                Question(
                    id: 2,
                    domain: .sectionB,
                    archetype: "Direct Diagnostic",
                    question: "During a manual transmission rebuild, a technician presses a new brass synchronizer blocking ring onto its mating gear cone and measures the gap between the blocking ring face and the gear clutch teeth using a feeler gauge. The gap measures 0.008 in. (0.20 mm), while the minimum service limit is 0.020 in. (0.50 mm). What will happen if this blocking ring is reused?",
                    options: [
                        "The blocking ring will bottom out against the gear face before its cone can brake the gear to synchronous speed, causing gear clash (grinding)",
                        "The transmission will lock into two gears simultaneously at highway speed",
                        "The clutch pedal free play will increase by 1.5 inches",
                        "The speedometer will read 20% higher than actual vehicle speed"
                    ],
                    correctIndex: 0,
                    rationale: "Synchronizer blocking rings rely on friction between their internal tapered cone threads and the gear cone to equalize shaft speeds before the sleeve slides over the teeth. When the gap wears below specification, the ring bottoms out without braking the gear, causing shift clash."
                ),
                Question(
                    id: 3,
                    domain: .sectionC,
                    archetype: "MOST Likely",
                    question: "A front-wheel-drive vehicle produces a rhythmic metallic clicking and popping noise from the left front wheel area ONLY when accelerating while turning the steering wheel sharply to the left or right. What is the MOST likely cause?",
                    options: [
                        "A worn outer Rzeppa constant-velocity (CV) joint on the front half shaft",
                        "A worn inner tripod plunging CV joint near the transaxle differential",
                        "A failing clutch release (throw-out) bearing on the input shaft quill",
                        "Low gear lubricant level inside the manual transaxle case"
                    ],
                    correctIndex: 0,
                    rationale: "Outer ball-type (Rzeppa) CV joints articulate through wide steering angles; wear in their ball tracks causes a sharp rhythmic click under load during turns. By contrast, worn inner tripod joints typically cause a shudder under straight-line acceleration."
                ),
                Question(
                    id: 4,
                    domain: .sectionD,
                    archetype: "Technician A / B",
                    question: "While checking the yellow gear-marking compound pattern on a hypoid rear differential ring gear after assembly, the technician observes heavy contact concentrated at the very top edge of the ring gear teeth ('face contact') on both drive and coast sides. Technician A says moving the pinion gear closer to the ring gear centerline (adding shim thickness on a standard shim-behind-cup design) will move the contact pattern deeper toward the root. Technician B says ring-and-pinion backlash must be rechecked and adjusted any time pinion depth is changed. Who is correct?",
                    options: [
                        "Technician A only",
                        "Technician B only",
                        "Both Technician A and Technician B",
                        "Neither Technician A nor Technician B"
                    ],
                    correctIndex: 2,
                    rationale: "Both technicians are correct. High face contact toward the tooth crest means the pinion is positioned too far away (shallow) from the ring gear centerline. Moving the pinion deeper lowers contact into the center of the tooth profile, and changing pinion depth alters backlash, requiring carrier shim readjustment."
                )
            ]
        case .a4:
            return [
                Question(
                    id: 1,
                    domain: .sectionA,
                    archetype: "Direct Diagnostic",
                    question: "After replacing a tied rod end and performing a four-wheel alignment on a vehicle equipped with Electric Power Steering (EPS) and Electronic Stability Control (ESC), what final procedure MUST be performed with a scan tool to prevent steering pull or an ESC warning light?",
                    options: [
                        "Reset and calibrate the Steering Angle Sensor (SAS) zero-point with the front wheels pointed straight ahead",
                        "Bleed the EPS electric motor brushes using DOT 4 brake fluid",
                        "Inflate the front tires to 65 psi for the first 100 miles",
                        "Disconnect the alternator field wire and road test at 55 mph"
                    ],
                    correctIndex: 0,
                    rationale: "EPS and ESC modules use the Steering Angle Sensor (SAS) to determine straight-ahead driver intent and provide active return-to-center torque assist. Changing mechanical toe shifts the steering column center relative to the wheels, requiring a scan tool SAS zero-point calibration."
                ),
                Question(
                    id: 2,
                    domain: .sectionB,
                    archetype: "MOST Likely",
                    question: "When checking a load-carrying lower ball joint on a short-long arm (SLA) suspension where the coil spring rests on the lower control arm, where must the floor jack or safety stand be placed to unload the ball joint for radial/axial play inspection?",
                    options: [
                        "Directly underneath the outer end of the lower control arm as close to the lower ball joint as possible",
                        "Underneath the center of the rear bumper reinforcement beam",
                        "Underneath the body pinch weld so the front suspension hangs at full rebound droop",
                        "On top of the upper control arm bushing pivot shaft"
                    ],
                    correctIndex: 0,
                    rationale: "When the spring sits on the lower control arm, lifting the vehicle by the frame lets spring tension wedge the lower ball joint stud tightly into its socket, hiding wear. Supporting the outer lower control arm compresses the spring and unloads the ball joint so play can be measured with a dial indicator."
                ),
                Question(
                    id: 3,
                    domain: .sectionC,
                    archetype: "Direct Diagnostic",
                    question: "A vehicle drifts steadily to the right on a flat, level road. Alignment readings show: Left Front Caster +4.8°, Right Front Caster +2.6°, Left Front Camber -0.2°, Right Front Camber -0.2°, Total Toe +0.10°. Why is the vehicle pulling to the right?",
                    options: [
                        "A vehicle always pulls toward the side with the LEAST positive caster (Right Front at +2.6°) and MOST positive camber",
                        "Excessive positive total toe causes a one-way pull to the right lane",
                        "Equal negative camber (-0.2° on both sides) forces the steering rack to the right",
                        "Left Front Caster of +4.8° pushes the vehicle to the left shoulder"
                    ],
                    correctIndex: 0,
                    rationale: "In wheel alignment physics, a vehicle leads or pulls toward the side with the MOST positive camber or the LEAST positive caster. Here, Right Front caster (+2.6°) is 2.2° less positive than Left Front (+4.8°), causing a strong caster pull to the right."
                ),
                Question(
                    id: 4,
                    domain: .sectionD,
                    archetype: "MOST Likely",
                    question: "A customer complains of a smooth, rhythmic vertical bounce ('wheel hop') felt between 55 and 65 mph on smooth pavement. Using a dial indicator against the tire tread while spinning the wheel reveals 0.095 in. (2.4 mm) of radial runout, while the alloy wheel rim flange has only 0.010 in. of radial runout. After match-mounting and road-force balancing, road force variation still measures 38 lbs. What is the MOST likely cause?",
                    options: [
                        "An out-of-round tire or internal belt stiffness variation requiring tire replacement",
                        "Warped rear disc brake rotors",
                        "Excessive front wheel toe-in adjustment",
                        "A binding upper MacPherson strut bearing plate"
                    ],
                    correctIndex: 0,
                    rationale: "Radial runout exceeding ~0.045–0.060 in. and road force variation above 20–26 lbs on a straight wheel rim (0.010 in. runout) confirms that the tire carcass itself is out-of-round or has excessive radial stiffness variation."
                )
            ]
        case .a5:
            return [
                Question(
                    id: 1,
                    domain: .sectionA,
                    archetype: "MOST Likely",
                    question: "A customer complains that the brake pedal feels firm when first pressed at a red light, but slowly sinks all the way to the floorboard if steady foot pressure is held for 15 seconds. The brake fluid reservoir is full, and a visual inspection of all four calipers, hoses, and steel lines shows zero external fluid leaks. What is the MOST likely cause?",
                    options: [
                        "Fluid bypassing internally past worn primary piston cup seals inside the brake master cylinder bore",
                        "A ruptured diaphragm inside the vacuum power brake booster",
                        "Excessive lateral runout on both front disc brake rotors",
                        "A seized rear parking brake equalizer cable"
                    ],
                    correctIndex: 0,
                    rationale: "A brake pedal that slowly sinks to the floor under light, steady foot pressure with no external fluid loss is the classic symptom of internal fluid bypass past the primary cup seals inside the master cylinder."
                ),
                Question(
                    id: 2,
                    domain: .sectionB,
                    archetype: "Direct Diagnostic",
                    question: "On a duo-servo rear drum brake assembly having one shorter brake shoe lining and one longer brake shoe lining, where must the shorter ('primary') brake shoe be installed?",
                    options: [
                        "Toward the FRONT of the vehicle, facing forward",
                        "Toward the REAR of the vehicle, facing the rear bumper",
                        "Both short shoes on the driver side and both long shoes on the passenger side",
                        "Directly underneath the star-wheel adjuster screw at the bottom"
                    ],
                    correctIndex: 0,
                    rationale: "In a duo-servo drum brake design, forward drum rotation pulls the forward (primary) shoe away from the anchor pin and drives it into the star adjuster, multiplying force onto the rear (secondary) shoe. Because the secondary shoe does ~65–70% of the braking work, it has the longer/thicker lining and goes toward the rear, while the shorter primary shoe goes toward the front."
                ),
                Question(
                    id: 3,
                    domain: .sectionC,
                    archetype: "Direct Diagnostic",
                    question: "A technician measures a front disc brake rotor with an outside micrometer and records a thickness of 1.032 in. (26.21 mm). Cast into the rotor hat are the specifications: 'NOM 1.100 IN / MIN THICK 1.040 IN'. What action must the technician take?",
                    options: [
                        "Replace the brake rotor, because its current thickness (1.032 in.) is already below the minimum safe thickness specification (1.040 in.)",
                        "Machine 0.015 in. off each side of the rotor on a brake lathe to true the surfaces",
                        "Install two steel shims behind the outboard brake pad to make up the 0.008 in. difference",
                        "Scuff the rotor with sandpaper and reuse it since discard thickness is 0.090 in. lower"
                    ],
                    correctIndex: 0,
                    rationale: "Minimum Thickness ('MIN THICK') is the minimum allowable thickness AFTER machining (or discard limit). Because 1.032 in. is thinner than 1.040 in., the rotor cannot dissipate heat safely or retain piston seal support and must be replaced."
                ),
                Question(
                    id: 4,
                    domain: .sectionD,
                    archetype: "Direct Diagnostic",
                    question: "To test a vacuum-assisted power brake booster, the technician pumps the brake pedal several times with the engine OFF to deplete all vacuum reserve, then holds firm pressure on the brake pedal while starting the engine. How should the brake pedal respond on a properly functioning vacuum booster?",
                    options: [
                        "The brake pedal should drop slightly downward under foot pressure as intake manifold vacuum builds and assists the diaphragm",
                        "The brake pedal should kick forcefully upward against the driver's foot by 2 inches",
                        "The brake pedal should remain rock-hard at the exact same height without moving",
                        "The ABS pump motor should buzz continuously for 30 seconds"
                    ],
                    correctIndex: 0,
                    rationale: "When the engine starts and manifold vacuum evacuates the front chamber of the brake booster, atmospheric pressure behind the diaphragm pushes the pushrod forward, causing the pedal to drop slightly under the driver's foot."
                ),
                Question(
                    id: 5,
                    domain: .sectionE,
                    archetype: "MOST Likely",
                    question: "A customer complains that the ABS pump activates and the brake pedal pulsates during almost every normal, dry-pavement stop at low speeds (below 10 mph), even though no ABS warning light is illuminated. Watching all four Wheel Speed Sensor (WSS) signals on a graphing scan tool while coasting to a stop shows the Left Front WSS signal dropping cleanly to 0 mph at 7 mph while the other three sensors read 7 mph. What is the MOST likely cause?",
                    options: [
                        "Excessive air gap or rust jacking under a passive (variable-reluctance) Left Front wheel speed sensor",
                        "Air trapped inside the master cylinder primary hydraulic circuit",
                        "Glazed rear drum brake linings",
                        "A blown 40-amp ABS pump motor maxi-fuse"
                    ],
                    correctIndex: 0,
                    rationale: "On a variable-reluctance (passive magnetic) wheel speed sensor, rust buildup ('rust jacking') under the sensor mounting boss increases the air gap to the tone ring. At low speeds (<10 mph), the weakened AC sine wave voltage drops below the ABS module's threshold first, fooling the module into thinking the Left Front wheel just locked up on ice and triggering false low-speed ABS activation."
                )
            ]
        case .a6:
            return [
                Question(
                    id: 1,
                    domain: .sectionA,
                    archetype: "Direct Diagnostic",
                    question: "A 12-volt exterior lighting circuit protected by a 15-amp fuse contains two 4-ohm bulbs wired in parallel. According to Ohm's Law, what is the total equivalent circuit resistance and the total current flow when supplied with 12.0 volts?",
                    options: [
                        "2.0 ohms total resistance and 6.0 amps total current",
                        "8.0 ohms total resistance and 1.5 amps total current",
                        "4.0 ohms total resistance and 3.0 amps total current",
                        "16.0 ohms total resistance and 0.75 amps total current"
                    ],
                    correctIndex: 0,
                    rationale: "For two equal 4-ohm resistors in parallel, Total Resistance R_t = 4 / 2 = 2.0 ohms. By Ohm's Law (I = E / R), Total Current I = 12.0 V / 2.0 ohms = 6.0 amps (3.0 amps through each branch)."
                ),
                Question(
                    id: 2,
                    domain: .sectionB,
                    archetype: "MOST Likely",
                    question: "A vehicle exhibits a parasitic battery drain that kills the battery overnight. With all doors latched, modules asleep, and an ammeter connected in series with the negative battery cable, the parasitic draw reads 480 milliamps (0.48 A) instead of the normal <35 mA specification. What is the BEST way to isolate the offending circuit without waking up sleeping body control modules?",
                    options: [
                        "Measure millivolt (mV) voltage drop across the test points on top of each blade fuse without pulling the fuses",
                        "Pull and reinstall every fuse in the underhood and interior fuse boxes one at a time",
                        "Disconnect the positive battery cable while the engine is running at 2,000 RPM",
                        "Perform an Ohmmeter resistance check across the battery terminals with the cables connected"
                    ],
                    correctIndex: 0,
                    rationale: "Pulling and reinstalling fuses can reset or wake up sleeping modules, hiding the draw. Measuring microvolt/millivolt drop across the exposed test tabs of each blade fuse identifies which fuse has current flowing through it without interrupting circuit power."
                ),
                Question(
                    id: 3,
                    domain: .sectionC,
                    archetype: "MOST Likely",
                    question: "During a charging system output test at 2,000 RPM with the electrical load on, the alternator produces 13.9 Volts DC and 85 Amps, which meets specification—yet the battery still becomes undercharged, and a DMM connected between the alternator B+ output stud and the positive battery post reads 0.95 Volts DC. What is the MOST likely cause?",
                    options: [
                        "High resistance (corrosion or loose crimps) in the alternator B+ charging cable or fusible link (>0.5V drop limit)",
                        "An open rotor field winding inside the alternator",
                        "A shorted cell inside the 12-volt storage battery",
                        "A slipping serpentine belt on the water pump pulley"
                    ],
                    correctIndex: 0,
                    rationale: "Maximum allowable voltage drop on the positive side of the charging circuit under full load is 0.4 to 0.5 Volts DC. A 0.95V drop between the alternator B+ stud and battery positive post means nearly 1 full volt is being lost across resistance in the B+ cable/connections."
                ),
                Question(
                    id: 4,
                    domain: .sectionD,
                    archetype: "Direct Diagnostic",
                    question: "On a vehicle using a single-wire resistive fuel level sender where the instrument cluster supplies a 5V reference and reads high resistance as Empty and low resistance as Full, the fuel gauge suddenly drops to Empty and stays there. When the technician unplugs the fuel tank harness and jumpers the sender signal wire directly to a clean chassis ground, the gauge needle sweeps all the way to Full. What does this confirm?",
                    options: [
                        "The instrument cluster, wiring harness, and ground are good; the open circuit is inside the fuel tank sender unit",
                        "The instrument cluster stepper motor is mechanically seized at Empty",
                        "The signal wire between the dash and the fuel tank is shorted to ground",
                        "The 5-volt reference regulator inside the BCM has failed"
                    ],
                    correctIndex: 0,
                    rationale: "Because grounding the signal wire at the rear tank connector causes the dash gauge to respond properly (sweeping from Empty to Full), the cluster and chassis harness are proven intact; the fault is an open circuit inside the tank module's sender wiper or ground path."
                ),
                Question(
                    id: 5,
                    domain: .sectionE,
                    archetype: "Direct Diagnostic",
                    question: "With the vehicle battery disconnected, a technician connects an ohmmeter across Pin 6 (CAN-High) and Pin 14 (CAN-Low) of the 16-pin OBD-II Data Link Connector (DLC) to check the high-speed CAN bus terminating resistors. The meter reads 120 ohms instead of the normal 60 ohms. What does a 120-ohm reading indicate?",
                    options: [
                        "One of the two parallel 120-ohm terminating resistors is open (or one branch of the CAN bus backbone is open)",
                        "CAN-High and CAN-Low wires are shorted directly together",
                        "The high-speed CAN bus termination resistance is completely normal",
                        "All control modules on the bus have shorted power supplies"
                    ],
                    correctIndex: 0,
                    rationale: "A high-speed ISO 11898 CAN bus uses two 120-ohm terminating resistors wired in parallel at opposite ends of the bus backbone, producing a total resistance of 60 ohms (120 / 2 = 60). Reading 120 ohms means one terminating resistor (or the twisted-pair wiring leading to it) is open."
                )
            ]
        case .a7:
            return [
                Question(
                    id: 1,
                    domain: .sectionA,
                    archetype: "MOST Likely",
                    question: "On an 85°F (29°C) day, a technician connects manifold gauges to an R-134a A/C system that uses a thermal expansion valve (TXV) and records: Low Side = 2 psi (in vacuum on throttle snap), High Side = 115 psi (normal is ~210 psi). The liquid line entering the TXV is warm, but heavy frost is forming directly on the outlet body of the TXV. What is the MOST likely cause?",
                    options: [
                        "The Thermal Expansion Valve (TXV) is stuck closed or restricted by moisture/debris",
                        "The condenser cooling fan is inoperative",
                        "The system is overcharged with 1.5 lbs of extra R-134a refrigerant",
                        "The A/C compressor reed valves are broken and bypassing internally"
                    ],
                    correctIndex: 0,
                    rationale: "Low/vacuum suction pressure paired with low discharge pressure and frost right at the TXV outlet indicates a restriction inside the TXV (stuck closed or iced up), starving the evaporator of refrigerant while the compressor pulls the low side into a vacuum."
                ),
                Question(
                    id: 2,
                    domain: .sectionB,
                    archetype: "Direct Diagnostic",
                    question: "When servicing a hybrid or battery-electric vehicle (EV) equipped with a high-voltage electric scroll A/C compressor, why MUST the technician use only non-conductive Polyolester (POE) refrigerant oil (such as ND-OIL 11) rather than standard Polyalkylene Glycol (PAG) oil?",
                    options: [
                        "Standard PAG oil is hygroscopic and electrically conductive, which can cause high-voltage insulation breakdown and dangerous electrical leakage through the motor windings",
                        "POE oil increases the boiling point of engine antifreeze in the radiator",
                        "PAG oil solidifies into wax at temperatures above 70°F",
                        "Electric scroll compressors do not use any liquid refrigerant"
                    ],
                    correctIndex: 0,
                    rationale: "In a high-voltage electric A/C compressor (200V–400V+), the refrigerant and lubricating oil flow directly across the internal electric motor stator windings to cool them. Standard PAG oil conducts electricity; dielectric POE oil is mandatory to prevent high-voltage isolation faults."
                ),
                Question(
                    id: 3,
                    domain: .sectionC,
                    archetype: "MOST Likely",
                    question: "A customer complains of lukewarm cabin heat in winter even though the engine temperature gauge reads a steady 195°F (90°C). With the engine fully warm and the HVAC set to full HOT, the technician feels both heater core hoses at the firewall: the heater inlet hose is hot (190°F), while the heater outlet hose is cool (95°F). What is the MOST likely cause?",
                    options: [
                        "A restricted/plugged heater core restricting coolant flow through the core tubes",
                        "A cooling system thermostat stuck in the wide-open position",
                        "A broken temperature blend door actuator stuck in the full-heat position",
                        "An overfilled coolant recovery reservoir"
                    ],
                    correctIndex: 0,
                    rationale: "A hot heater core inlet hose combined with a cool outlet hose proves that 190°F coolant is reaching the core, but very little coolant is flowing through it—letting the blower fan strip all heat from the trickle of coolant before it exits."
                ),
                Question(
                    id: 4,
                    domain: .sectionD,
                    archetype: "Direct Diagnostic",
                    question: "On a dual-zone automatic climate control system, the driver side blows ice-cold 42°F air while the passenger side blows hot 125°F air regardless of the passenger temperature knob setting. Both low- and high-side A/C pressures are normal. What component should the technician inspect FIRST?",
                    options: [
                        "The passenger-side electric temperature blend door actuator and door linkage",
                        "The A/C compressor clutch air gap",
                        "The cabin air filter element behind the glovebox",
                        "The radiator pressure cap relief valve"
                    ],
                    correctIndex: 0,
                    rationale: "Because the driver side is blowing 42°F air, the refrigeration system and evaporator are cooling normally. In a dual-zone system, separate left and right electric blend door actuators direct air through or around the heater core; a stripped gear or failed actuator on the passenger side leaves that zone stuck on full heat."
                )
            ]
        case .a8:
            return [
                Question(
                    id: 1,
                    domain: .sectionA,
                    archetype: "MOST Likely",
                    question: "A V6 engine sets DTC P0171 (Bank 1 System Too Lean) and P0174 (Bank 2 System Too Lean). At idle (700 RPM), Short-Term Fuel Trims on both banks are +4% and Long-Term Fuel Trims are +6%. However, under wide-open throttle acceleration at 4,000 RPM, Short-Term Fuel Trims spike to +24% on BOTH banks and the engine hesitates. What is the MOST likely cause?",
                    options: [
                        "Low fuel delivery volume/pressure (weak fuel pump or restricted filter) or a contaminated Mass Air Flow (MAF) sensor under-reporting high airflow",
                        "A cracked vacuum hose connected to the intake manifold plenum",
                        "An EGR valve pintle stuck slightly open at idle",
                        "Leaking fuel injectors dripping raw fuel into Bank 1"
                    ],
                    correctIndex: 0,
                    rationale: "An intake manifold vacuum leak causes high positive fuel trims at IDLE that disappear at high RPM. Conversely, fuel trims that are normal at idle (+4%) and climb severely positive (+24%) under high load/RPM point to fuel starvation under high demand or a dirty MAF sensor under-reporting air mass."
                ),
                Question(
                    id: 2,
                    domain: .sectionB,
                    archetype: "Direct Diagnostic",
                    question: "While diagnosing an Electronic Throttle Control (ETC) 'Reduced Engine Power' fault, the technician graphs Throttle Position Sensor 1 (TPS1) and Sensor 2 (TPS2) inside the throttle body. On a typical inverse-voltage ETC design, as the throttle plate opens from idle to wide-open throttle, how should TPS1 and TPS2 voltages behave?",
                    options: [
                        "TPS1 voltage increases linearly from ~0.5V to ~4.5V while TPS2 voltage decreases linearly from ~4.5V to ~0.5V (always summing to ~5.0V)",
                        "Both TPS1 and TPS2 remain constant at 2.50V at all throttle angles",
                        "TPS1 generates 120V AC while TPS2 generates 12V DC",
                        "TPS1 and TPS2 only change voltage when the brake pedal is depressed"
                    ],
                    correctIndex: 0,
                    rationale: "For redundancy and plausibility checking, most ETC throttle bodies use two independent potentiometers (or Hall-effect sensors) with inverse voltage slopes (or a 2:1 voltage ratio) so the PCM can immediately detect any wiring short, open, or sensor drift."
                ),
                Question(
                    id: 3,
                    domain: .sectionC,
                    archetype: "Direct Diagnostic",
                    question: "When analyzing a secondary ignition kilovolt (kV) waveform on a lab scope, Cylinder #4 shows a firing line peak of 24 kV and a very short spark duration of 0.4 milliseconds, while all other cylinders show a 10 kV firing line and 1.5 ms spark duration. What causes high firing kV paired with short burn time on a single cylinder?",
                    options: [
                        "Excessively wide spark plug electrode gap, an open/high-resistance plug wire/boot, or a lean mixture in Cylinder #4",
                        "A carbon-fouled spark plug tip shorted to ground in Cylinder #4",
                        "Low cranking compression (75 psi) in Cylinder #4",
                        "An overly rich air-fuel mixture in Cylinder #4"
                    ],
                    correctIndex: 0,
                    rationale: "High secondary resistance (such as a worn, wide spark plug gap or damaged coil boot) requires much higher voltage (24 kV) to ionize the gap. Once the coil expends most of its stored magnetic energy just jumping the gap, very little energy remains to sustain the spark line, resulting in a short burn duration (0.4 ms)."
                ),
                Question(
                    id: 4,
                    domain: .sectionD,
                    archetype: "MOST Likely",
                    question: "A wideband planar Air-Fuel Ratio (A/F) sensor (upstream B1S1) displays a lambda (λ) reading of 1.18 (equivalence ratio) on a scan tool while the engine is running at 2,000 RPM. What does a lambda value of 1.18 indicate?",
                    options: [
                        "The exhaust gas stream is LEAN (18% excess air compared to stoichiometric λ = 1.00)",
                        "The exhaust gas stream is RICH (18% excess fuel compared to stoichiometric λ = 1.00)",
                        "The catalytic converter substrate is melted shut",
                        "The alternator charging voltage is 11.8 Volts"
                    ],
                    correctIndex: 0,
                    rationale: "Lambda (λ) is the ratio of actual air-fuel ratio to stoichiometric air-fuel ratio (14.7:1 for gasoline). Lambda = 1.00 is stoichiometric; Lambda > 1.00 (such as 1.18) means excess air (LEAN), while Lambda < 1.00 (such as 0.85) means excess fuel (RICH)."
                ),
                Question(
                    id: 5,
                    domain: .sectionE,
                    archetype: "MOST Likely",
                    question: "A customer complains that the engine is hard to start (requiring 8–10 seconds of cranking and producing black smoke) ONLY immediately after refueling the vehicle at a gas station. At all other times, the engine starts instantly, and DTC P0496 (EVAP High Purge Flow) is stored. What is the MOST likely cause?",
                    options: [
                        "The normally closed EVAP canister purge solenoid valve is stuck OPEN, drawing fuel vapors from the tank into the intake manifold during refueling",
                        "The EVAP canister fresh-air vent solenoid is stuck in the normally open position",
                        "The fuel filler cap rubber O-ring is missing",
                        "The fuel tank pressure (FTP) sensor 5V reference wire is open"
                    ],
                    correctIndex: 0,
                    rationale: "As liquid gasoline fills the tank at the pump, it displaces a large volume of rich fuel vapor into the charcoal canister. If the intake manifold EVAP purge valve is stuck OPEN, those displaced vapors are pushed straight through the open purge line into the intake plenum, flooding the engine for the post-refuel start."
                )
            ]
        case .a9:
            return [
                Question(
                    id: 1,
                    domain: .sectionA,
                    archetype: "MOST Likely",
                    question: "A light-duty common-rail turbo-diesel engine cranks over at normal speed on a 25°F (-4°C) morning, builds 4,800 psi of rail pressure during cranking, but fails to start and billows thick, unburned white/gray fuel smoke from the tailpipe. Once plugged into a block heater for an hour, it starts and runs smoothly. What is the MOST likely cause?",
                    options: [
                        "An inoperative glow plug control module or multiple open glow plugs failing to heat the combustion chambers",
                        "A seized high-pressure common-rail CP4 fuel injection pump",
                        "A plugged Diesel Particulate Filter (DPF) substrate",
                        "Low engine oil level in the crankcase"
                    ],
                    correctIndex: 0,
                    rationale: "Thick white/gray raw diesel vapor during cold cranking with normal rail pressure indicates that fuel is being injected into the cylinders, but cold compression temperature alone is insufficient to auto-ignite the mist without working glow plugs."
                ),
                Question(
                    id: 2,
                    domain: .sectionB,
                    archetype: "Direct Diagnostic",
                    question: "Modern diesel engines use low-voltage rapid-heat glow plugs (such as 4.4V, 5V, or 7V ceramic/steel glow plugs) pulsed via PWM by the Glow Plug Control Module. What will happen if a technician tests a 4.4-volt fast-heat glow plug by connecting jumper wires directly to a 12-volt battery?",
                    options: [
                        "The glow plug tip will overheat instantly, swell, fracture, or melt inside the cylinder within seconds",
                        "The glow plug will take 60 seconds to warm up normally",
                        "The 12-volt battery will immediately discharge to 0 volts",
                        "Nothing, because all diesel glow plugs are rated for continuous 12V–24V operation"
                    ],
                    correctIndex: 0,
                    rationale: "Late-model fast-heat glow plugs are engineered for 4.4V to 7V PWM control so they reach 1,800°F+ in under 2 seconds. Applying direct 12V battery power burns out the heating element or causes the tip to mushroom/shatter."
                ),
                Question(
                    id: 3,
                    domain: .sectionC,
                    archetype: "Direct Diagnostic",
                    question: "After resurfacing the deck of a light-duty diesel engine block, why must the technician measure piston protrusion (piston height above the block deck at TDC) with a dial indicator and bridge fixture?",
                    options: [
                        "Diesel engines run minimal piston-to-head/valve clearance and high compression ratios (16:1–18:1), so piston protrusion dictates which thickness grade of Multi-Layer Steel (MLS) head gasket must be installed",
                        "To determine the size of the turbocharger wastegate actuator spring",
                        "To calibrate the Diesel Exhaust Fluid (DEF) dosing injector duty cycle",
                        "To set crankshaft axial thrust bearing end play"
                    ],
                    correctIndex: 0,
                    rationale: "Because diesel engines have flat cylinder heads and almost zero clearance between the piston crown and valves at TDC overlap, milling the block deck increases piston protrusion. Measuring protrusion at all cylinders determines which notched thickness grade (e.g., Grade A, B, or C) of MLS head gasket is required."
                ),
                Question(
                    id: 4,
                    domain: .sectionD,
                    archetype: "MOST Likely",
                    question: "A light-duty V8 turbo-diesel engine exhibits an Engine Oil Temperature (EOT) reading of 242°F (117°C) while Engine Coolant Temperature (ECT) reads 192°F (89°C) during steady 65 mph highway cruising (a 50°F EOT-to-ECT delta, where maximum spec is 15°F). What is the MOST likely cause?",
                    options: [
                        "A partially plugged liquid-to-liquid engine oil cooler (coolant passages restricted with silicate dropout/casting sand)",
                        "A stuck-open primary radiator cooling system thermostat",
                        "Excessive fuel dilution in the engine oil pan",
                        "An open circuit in the ambient air temperature sensor"
                    ],
                    correctIndex: 0,
                    rationale: "Diesel engines use a water-to-oil heat exchanger (oil cooler) to keep EOT within ~10–15°F of ECT at steady cruise. An EOT reading 30–50°F hotter than ECT indicates restricted coolant flow through the oil cooler."
                ),
                Question(
                    id: 5,
                    domain: .sectionE,
                    archetype: "Direct Diagnostic",
                    question: "In aSelective Catalytic Reduction (SCR) diesel aftertreatment system, what is the standard chemical composition of Diesel Exhaust Fluid (DEF), and what optical instrument is used in the shop to verify its concentration?",
                    options: [
                        "32.5% high-purity synthetic urea and 67.5% deionized water, verified with a DEF refractometer",
                        "50% ethylene glycol and 50% tap water, verified with a floating ball hydrometer",
                        "15% cetane improver and 85% ultra-low-sulfur diesel fuel, verified with a pressure gauge",
                        "100% anhydrous ammonia gas, verified with a digital multimeter"
                    ],
                    correctIndex: 0,
                    rationale: "ISO 22241 Diesel Exhaust Fluid (DEF) consists of exactly 32.5% high-purity urea in 67.5% deionized water (the eutectic concentration with the lowest freezing point of +12°F / -11°C). A calibrated optical refractometer verifies the 32.5% concentration."
                )
            ]
        }
    }
}

// MARK: - Liquid Glass & Legacy iOS Adaptive Surface Modifiers

extension View {
    /// Applies an adaptive card surface with a diagonal Liquid Glass specular rim stroke.
    func liquidGlassCard(cornerRadius: CGFloat = 16) -> some View {
        self
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.32),
                                Color.white.opacity(0.08),
                                Color.clear,
                                Color.white.opacity(0.14)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

    /// Applies a floating translucent Liquid Glass pill/bar container that refracts scrolling content underneath.
    func liquidGlassFloatingBar(cornerRadius: CGFloat = 22) -> some View {
        self
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.45),
                                Color.white.opacity(0.12),
                                Color.white.opacity(0.22)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 4)
    }
}
