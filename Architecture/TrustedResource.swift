import Foundation

enum TrustedResourceCategory: String, CaseIterable, Identifiable {
    case collegePlanning = "College Planning"
    case financialAid = "Financial Aid"
    case athletics = "Athletics"
    case testing = "Testing"
    case careers = "Careers"
    case apprenticeships = "Apprenticeships"
    case service = "Service"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .collegePlanning: return "building.columns"
        case .financialAid: return "dollarsign.circle"
        case .athletics: return "figure.run"
        case .testing: return "pencil.and.list.clipboard"
        case .careers: return "briefcase"
        case .apprenticeships: return "hammer"
        case .service: return "heart.hand"
        }
    }
}

struct TrustedResource: Identifiable, Hashable {
    let id: String
    let organization: String
    let title: String
    let description: String
    let url: URL
    let category: TrustedResourceCategory
    let resourceType: String
    let audience: String
    let officialSource: Bool
    let lastVerified: String
}

enum TrustedResourceCatalog {
    static let resources: [TrustedResource] = [
        TrustedResource(
            id: "bigfuture",
            organization: "College Board",
            title: "BigFuture",
            description: "Explore colleges, majors, careers, scholarships, and planning steps for life after high school.",
            url: URL(string: "https://bigfuture.collegeboard.org/plan-for-college")!,
            category: .collegePlanning,
            resourceType: "Planning tools",
            audience: "Students and families",
            officialSource: true,
            lastVerified: "September 2026"
        ),
        TrustedResource(
            id: "common-app",
            organization: "Common App",
            title: "Common App Student Resources",
            description: "Guides, checklists, and application resources for students applying to participating colleges.",
            url: URL(string: "https://www.commonapp.org/apply/student-guides-and-resources/")!,
            category: .collegePlanning,
            resourceType: "Application guidance",
            audience: "College applicants",
            officialSource: true,
            lastVerified: "September 2026"
        ),
        TrustedResource(
            id: "fafsa",
            organization: "U.S. Department of Education",
            title: "Federal Student Aid / FAFSA",
            description: "Official federal financial aid information and the FAFSA application.",
            url: URL(string: "https://studentaid.gov/h/apply-for-aid/fafsa")!,
            category: .financialAid,
            resourceType: "Financial aid application",
            audience: "Students and families",
            officialSource: true,
            lastVerified: "September 2026"
        ),
        TrustedResource(
            id: "css-profile",
            organization: "College Board",
            title: "CSS Profile",
            description: "Apply for nonfederal institutional financial aid at participating colleges and scholarship programs.",
            url: URL(string: "https://cssprofile.collegeboard.org/")!,
            category: .financialAid,
            resourceType: "Financial aid application",
            audience: "Students and families",
            officialSource: true,
            lastVerified: "September 2026"
        ),
        TrustedResource(
            id: "ncaa-guide",
            organization: "NCAA",
            title: "Guide for the College-Bound Student-Athlete",
            description: "NCAA guidance for students considering college athletics and the eligibility process.",
            url: URL(string: "https://on.ncaa.com/CBSA_HS_Portal")!,
            category: .athletics,
            resourceType: "Student-athlete guide",
            audience: "Prospective college student-athletes",
            officialSource: true,
            lastVerified: "September 2026"
        ),
        TrustedResource(
            id: "ncaa-member-schools",
            organization: "NCAA",
            title: "NCAA Member Schools",
            description: "Find NCAA member colleges and universities by division and other criteria.",
            url: URL(string: "https://web1.ncaa.org/memberLinks/links.jsp?div=1")!,
            category: .athletics,
            resourceType: "School directory",
            audience: "Prospective college student-athletes",
            officialSource: true,
            lastVerified: "September 2026"
        ),
        TrustedResource(
            id: "ncaa-eligibility",
            organization: "NCAA",
            title: "NCAA Eligibility Center",
            description: "Learn about initial eligibility requirements, account options, registration, and next steps.",
            url: URL(string: "https://www.ncaa.org/eligibility-center/")!,
            category: .athletics,
            resourceType: "Eligibility information",
            audience: "Prospective college student-athletes",
            officialSource: true,
            lastVerified: "September 2026"
        ),
        TrustedResource(
            id: "naia-eligibility",
            organization: "NAIA",
            title: "PlayNAIA Eligibility Center",
            description: "Eligibility and registration resources for students interested in competing at NAIA schools.",
            url: URL(string: "https://play.mynaia.org/")!,
            category: .athletics,
            resourceType: "Eligibility information",
            audience: "Prospective college student-athletes",
            officialSource: true,
            lastVerified: "September 2026"
        ),
        TrustedResource(
            id: "sat",
            organization: "College Board",
            title: "SAT",
            description: "Official SAT registration, preparation, test-day, and score information.",
            url: URL(string: "https://satsuite.collegeboard.org/sat")!,
            category: .testing,
            resourceType: "Testing",
            audience: "College-bound students",
            officialSource: true,
            lastVerified: "September 2026"
        ),
        TrustedResource(
            id: "act",
            organization: "ACT",
            title: "The ACT Test",
            description: "Official ACT registration, preparation, test-day, score, and fee-waiver information.",
            url: URL(string: "https://www.act.org/content/act/en/products-and-services/the-act.html")!,
            category: .testing,
            resourceType: "Testing",
            audience: "College-bound students",
            officialSource: true,
            lastVerified: "September 2026"
        ),
        TrustedResource(
            id: "bls-ooh",
            organization: "U.S. Bureau of Labor Statistics",
            title: "Occupational Outlook Handbook",
            description: "Explore what people do at work, education and training requirements, pay, and job outlook for hundreds of careers.",
            url: URL(string: "https://www.bls.gov/ooh/")!,
            category: .careers,
            resourceType: "Career exploration",
            audience: "Students and job seekers",
            officialSource: true,
            lastVerified: "September 2026"
        ),
        TrustedResource(
            id: "careeronestop",
            organization: "U.S. Department of Labor",
            title: "CareerOneStop",
            description: "Explore careers, training options, skills, salaries, and job-search resources.",
            url: URL(string: "https://www.careeronestop.org/")!,
            category: .careers,
            resourceType: "Career exploration",
            audience: "Students and job seekers",
            officialSource: true,
            lastVerified: "September 2026"
        ),
        TrustedResource(
            id: "apprenticeship-finder",
            organization: "U.S. Department of Labor",
            title: "Apprenticeship Job Finder",
            description: "Search for apprenticeship opportunities by career field, employer, and location.",
            url: URL(string: "https://www.apprenticeship.gov/apprenticeship-job-finder")!,
            category: .apprenticeships,
            resourceType: "Opportunity finder",
            audience: "Students and job seekers",
            officialSource: true,
            lastVerified: "September 2026"
        ),
        TrustedResource(
            id: "americorps",
            organization: "AmeriCorps",
            title: "AmeriCorps",
            description: "Explore national service opportunities and ways to serve communities across the United States.",
            url: URL(string: "https://www.americorps.gov/serve")!,
            category: .service,
            resourceType: "Service opportunities",
            audience: "Students and young adults",
            officialSource: true,
            lastVerified: "September 2026"
        )
    ]
}
