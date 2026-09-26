import Foundation

enum TrustedResourceCategory: String, CaseIterable, Identifiable {
    case collegePlanning = "College Planning"
    case financialAid = "Financial Aid"
    case athletics = "Athletics"
    case testing = "Testing"
    case testPractice = "Test Practice"
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
        case .testPractice: return "checklist"
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
    let accessNote: String?

    init(
        id: String,
        organization: String,
        title: String,
        description: String,
        url: URL,
        category: TrustedResourceCategory,
        resourceType: String,
        audience: String,
        officialSource: Bool,
        lastVerified: String,
        accessNote: String? = nil
    ) {
        self.id = id
        self.organization = organization
        self.title = title
        self.description = description
        self.url = url
        self.category = category
        self.resourceType = resourceType
        self.audience = audience
        self.officialSource = officialSource
        self.lastVerified = lastVerified
        self.accessNote = accessNote
    }
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
            id: "sat-official-practice",
            organization: "College Board",
            title: "Official SAT Practice Tests",
            description: "Free official SAT practice, including full-length practice tests and answer explanations. College Board recommends Bluebook for the closest digital test experience.",
            url: URL(string: "https://satsuite.collegeboard.org/practice/practice-tests")!,
            category: .testPractice,
            resourceType: "SAT practice tests",
            audience: "Students preparing for the SAT",
            officialSource: true,
            lastVerified: "September 2026"
        ),
        TrustedResource(
            id: "act-official-practice",
            organization: "ACT",
            title: "Official ACT Practice Tests",
            description: "Free official ACT practice with full-length tests, sample questions, scoring information, and section-by-section practice.",
            url: URL(string: "https://www.act.org/content/act/en/products-and-services/the-act/test-preparation/free-act-test-prep.html")!,
            category: .testPractice,
            resourceType: "ACT practice tests",
            audience: "Students preparing for the ACT",
            officialSource: true,
            lastVerified: "September 2026"
        ),
        TrustedResource(
            id: "khan-sat-practice",
            organization: "Khan Academy",
            title: "Official Digital SAT Prep",
            description: "Free SAT lessons, practice questions, quizzes, and skill-building resources developed in partnership with College Board.",
            url: URL(string: "https://www.khanacademy.org/digital-sat")!,
            category: .testPractice,
            resourceType: "SAT practice",
            audience: "Students preparing for the SAT",
            officialSource: false,
            lastVerified: "September 2026",
            accessNote: "Free. You can view practice without an account, but an account is useful for saving and tracking your progress."
        ),
        TrustedResource(
            id: "princeton-sat-practice",
            organization: "The Princeton Review",
            title: "Free SAT Practice Test",
            description: "A free full-length SAT practice test with an online testing experience and score report.",
            url: URL(string: "https://www.princetonreview.com/college/free-sat-practice-test")!,
            category: .testPractice,
            resourceType: "SAT practice test",
            audience: "Students preparing for the SAT",
            officialSource: false,
            lastVerified: "September 2026",
            accessNote: "Free. Account setup or registration is required to access the practice test."
        ),
        TrustedResource(
            id: "princeton-act-practice",
            organization: "The Princeton Review",
            title: "Free ACT Practice Test",
            description: "A free ACT practice test and related practice resources designed to mirror the current ACT experience.",
            url: URL(string: "https://www.princetonreview.com/k12/free-act-practice-test")!,
            category: .testPractice,
            resourceType: "ACT practice test",
            audience: "Students preparing for the ACT",
            officialSource: false,
            lastVerified: "September 2026",
            accessNote: "Free. Account setup or registration is required to access the practice test."
        ),
        TrustedResource(
            id: "kaplan-sat-practice",
            organization: "Kaplan Test Prep",
            title: "Free Digital SAT Practice Test",
            description: "A free digital SAT practice test with score reporting, answer explanations, and additional practice resources.",
            url: URL(string: "https://www.kaptest.com/sat/free/sat-practice")!,
            category: .testPractice,
            resourceType: "SAT practice test",
            audience: "Students preparing for the SAT",
            officialSource: false,
            lastVerified: "September 2026",
            accessNote: "Free. Account setup or registration is required to access the practice test."
        ),
        TrustedResource(
            id: "kaplan-act-practice",
            organization: "Kaplan Test Prep",
            title: "Free ACT Practice",
            description: "Free ACT practice featuring official ACT questions, a half-length practice test, score insights, and additional practice options.",
            url: URL(string: "https://www.kaptest.com/act/free/act-free-practice-test")!,
            category: .testPractice,
            resourceType: "ACT practice",
            audience: "Students preparing for the ACT",
            officialSource: false,
            lastVerified: "September 2026",
            accessNote: "Free. Account setup or registration is required to access the practice experience."
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
