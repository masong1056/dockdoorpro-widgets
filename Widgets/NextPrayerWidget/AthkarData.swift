import Foundation

// MARK: - Category

enum DhikrCategory: String {
    case morning     = "Morning"
    case evening     = "Evening"
    case afterPrayer = "After Prayer"
    case general     = "General"

    var icon: String {
        switch self {
        case .morning:     return "sunrise.fill"
        case .evening:     return "sunset.fill"
        case .afterPrayer: return "hands.sparkles.fill"
        case .general:     return "sparkles"
        }
    }
}

// MARK: - Dhikr

struct Dhikr: Identifiable {
    let id: Int
    let arabic: String
    let transliteration: String
    let meaning: String
    let repetitions: Int
    let category: DhikrCategory
}

// MARK: - Curated list (from Hisnul Muslim / authentic sources)

enum AthkarData {

    static let all: [Dhikr] = [

        // MARK: Morning
        Dhikr(
            id: 1,
            arabic: "بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ",
            transliteration: "Bismillāhil-ladhī lā yaḍurru ma'asmihi shay'un fil-arḍi wa lā fis-samā'i, wa Huwas-Samī'ul-'Alīm",
            meaning: "In the name of Allah with Whose name nothing can harm in the earth or in the heaven. He is the All-Hearing, All-Knowing.",
            repetitions: 3,
            category: .morning
        ),
        Dhikr(
            id: 2,
            arabic: "اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ",
            transliteration: "Allāhumma anta rabbī lā ilāha illā ant, khalaqtanī wa anā 'abduk, wa anā 'alā 'ahdika wa wa'dika mastaṭa't",
            meaning: "O Allah, You are my Lord. None has the right to be worshipped but You. You created me and I am Your servant, faithful to my covenant and promise to You as much as I can.",
            repetitions: 1,
            category: .morning
        ),
        Dhikr(
            id: 3,
            arabic: "اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي، لَا إِلَهَ إِلَّا أَنْتَ",
            transliteration: "Allāhumma 'āfinī fī badanī, Allāhumma 'āfinī fī sam'ī, Allāhumma 'āfinī fī baṣarī, lā ilāha illā ant",
            meaning: "O Allah, grant me health in my body. O Allah, grant me health in my hearing. O Allah, grant me health in my sight. None has the right to be worshipped but You.",
            repetitions: 3,
            category: .morning
        ),
        Dhikr(
            id: 4,
            arabic: "رَضِيتُ بِاللَّهِ رَبًّا، وَبِالإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا",
            transliteration: "Raḍītu billāhi rabbā, wa bil-islāmi dīnā, wa bi-muḥammadin ﷺ nabiyyā",
            meaning: "I am pleased with Allah as my Lord, with Islam as my religion, and with Muhammad ﷺ as my Prophet.",
            repetitions: 3,
            category: .morning
        ),

        // MARK: Evening
        Dhikr(
            id: 5,
            arabic: "أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ",
            transliteration: "Amsaynā wa amsal-mulku lillāh, wal-ḥamdu lillāh, lā ilāha illallāhu waḥdahu lā sharīka lah, lahul-mulku wa lahul-ḥamdu wa huwa 'alā kulli shay'in qadīr",
            meaning: "We have reached the evening and the kingdom belongs to Allah. All praise is due to Allah. None has the right to be worshipped except Allah, alone, without partner. To Him belongs all sovereignty and praise, and He is over all things omnipotent.",
            repetitions: 1,
            category: .evening
        ),
        Dhikr(
            id: 6,
            arabic: "اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ الْمَصِيرُ",
            transliteration: "Allāhumma bika amsaynā, wa bika aṣbaḥnā, wa bika naḥyā, wa bika namūtu, wa ilaykal-maṣīr",
            meaning: "O Allah, by You we enter the evening and by You we enter the morning. By You we live and by You we die, and to You is our return.",
            repetitions: 1,
            category: .evening
        ),

        // MARK: After Prayer
        Dhikr(
            id: 7,
            arabic: "أَسْتَغْفِرُ اللَّهَ",
            transliteration: "Astaghfirullāh",
            meaning: "I seek forgiveness from Allah.",
            repetitions: 3,
            category: .afterPrayer
        ),
        Dhikr(
            id: 8,
            arabic: "اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ، تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ",
            transliteration: "Allāhumma antas-salāmu wa minkas-salām, tabārakta yā dhal-jalāli wal-ikrām",
            meaning: "O Allah, You are Peace and from You comes peace. Blessed are You, O Possessor of Glory and Honor.",
            repetitions: 1,
            category: .afterPrayer
        ),
        Dhikr(
            id: 9,
            arabic: "لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ",
            transliteration: "Lā ilāha illallāhu waḥdahu lā sharīka lah, lahul-mulku wa lahul-ḥamdu wa huwa 'alā kulli shay'in qadīr",
            meaning: "None has the right to be worshipped except Allah, alone, without partner. To Him belongs all sovereignty and praise, and He is over all things omnipotent.",
            repetitions: 10,
            category: .afterPrayer
        ),
        Dhikr(
            id: 10,
            arabic: "اللَّهُ لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ، لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ",
            transliteration: "Allāhu lā ilāha illā Huwal-Ḥayyul-Qayyūm, lā ta'khudhuhū sinatun wa lā nawm",
            meaning: "Allah — there is no deity except Him, the Ever-Living, the Sustainer of existence. Neither drowsiness overtakes Him nor sleep. (Opening of Ayat al-Kursi)",
            repetitions: 1,
            category: .afterPrayer
        ),

        // MARK: General
        Dhikr(
            id: 11,
            arabic: "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ سُبْحَانَ اللَّهِ الْعَظِيمِ",
            transliteration: "Subḥānallāhi wa biḥamdih, subḥānallāhil-'aẓīm",
            meaning: "Glory and praise be to Allah; glory be to Allah the Magnificent. Two phrases light on the tongue, heavy on the scale, beloved to the Most Merciful.",
            repetitions: 100,
            category: .general
        ),
        Dhikr(
            id: 12,
            arabic: "لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ",
            transliteration: "Lā ḥawla wa lā quwwata illā billāh",
            meaning: "There is no might nor power except with Allah.",
            repetitions: 1,
            category: .general
        ),
        Dhikr(
            id: 13,
            arabic: "سُبْحَانَ اللَّهِ، وَالْحَمْدُ لِلَّهِ، وَلَا إِلَهَ إِلَّا اللَّهُ، وَاللَّهُ أَكْبَرُ",
            transliteration: "Subḥānallāh, wal-ḥamdu lillāh, wa lā ilāha illallāh, wallāhu akbar",
            meaning: "Glory be to Allah. Praise be to Allah. None has the right to be worshipped but Allah. Allah is the Greatest.",
            repetitions: 1,
            category: .general
        ),
        Dhikr(
            id: 14,
            arabic: "اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ",
            transliteration: "Allāhumma ṣalli wa sallim 'alā nabiyyinā muḥammad",
            meaning: "O Allah, send prayers and peace upon our Prophet Muhammad.",
            repetitions: 10,
            category: .general
        ),
        Dhikr(
            id: 15,
            arabic: "حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ",
            transliteration: "Ḥasbiyallāhu lā ilāha illā Huwa 'alayhi tawakkaltu wa Huwa rabbul-'arshil-'aẓīm",
            meaning: "Allah is sufficient for me. None has the right to be worshipped but Him. In Him I have placed my trust, and He is the Lord of the Mighty Throne.",
            repetitions: 7,
            category: .general
        ),
    ]

    /// Returns a dhikr appropriate to the time of day, randomly selected.
    static func pick(for date: Date = Date()) -> Dhikr {
        let hour = Calendar.current.component(.hour, from: date)
        let candidates: [Dhikr]
        switch hour {
        case 4..<12:
            candidates = all.filter { $0.category == .morning || $0.category == .general }
        case 15..<21:
            candidates = all.filter { $0.category == .evening || $0.category == .afterPrayer || $0.category == .general }
        default:
            candidates = all
        }
        return (candidates.isEmpty ? all : candidates).randomElement() ?? all[0]
    }
}
