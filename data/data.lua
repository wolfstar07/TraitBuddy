local sf = string.format

local zones = {
	glenumbra = { id=3 },
	stormhaven = { id=19 },
	rivenspire = { id=20 },
	stonefalls = { id=41 },
	deshaan = { id=57 },
	malabaltor = { id=58 },
	bangkorai = { id=92 },
	eastmarch = { id=101 },
	therift = { id=103 },
	alikrdesert = { id=104 },
	greenshade = { id=108 },
	shadowfen = { id=117 },
	cyrodiil = { id=181, icon="esoui/art/treeicons/tutorial_idexicon_ava_up.dds" },
	eyevea = { id=267, icon="/esoui/art/treeicons/antiquities_tabicon_eyevea_up.dds" },
	coldharbour = { id=347, icon="/esoui/art/treeicons/antiquities_tabicon_coldharbour_up.dds" },
	auridon = { id=381 },
	reapersmarch = { id=382 },
	grahtwood = { id=383 },
	imperialcity = { id=584, icon="esoui/art/treeicons/tutorial_indexicon_ic_up.dds" },
	earthforge = { id=642, icon="esoui/art/icons/servicemappins/servicepin_fightersguild.dds" },
	wrothgar = { id=684, icon="esoui/art/treeicons/tutorial_idexicon_wrothgar_up.dds" },
	murkmire = { id=726, icon="esoui/art/treeicons/tutorial_idexicon_murkmire_up.dds" },
	hewsbane = { id=816, icon="esoui/art/treeicons/tutorial_idexicon_thievesguild_up.dds" },
	goldcoast = { id=823, icon="esoui/art/treeicons/tutorial_idexicon_darkbrotherhood_up.dds" },
	vvardenfell = { id=849, icon="esoui/art/treeicons/tutorial_idexicon_morrowind_up.dds" },
	craglorn = { id=888, icon="/esoui/art/treeicons/antiquities_tabicon_craglorn_up.dds" },
	clockwork = { id=980, icon="esoui/art/treeicons/tutorial_idexicon_cwc_up.dds" },
	brassfort = { id=981, icon="esoui/art/treeicons/tutorial_idexicon_cwc_up.dds" },
	summerset = { id=1011, icon="/esoui/art/icons/store_psijic_upgrade.dds" },
	artaeum = { id=1027, icon="/esoui/art/icons/store_psijic_upgrade.dds" },
	elsweyr_north = { id=1086, icon="esoui/art/treeicons/tutorial_idexicon_elsweyr_up.dds" },
	elsweyr_south = { id=1133, icon="esoui/art/treeicons/tutorial_idexicon_dragonguard_up.dds" },
	greymoor = { id=1160, icon="esoui/art/treeicons/tutorial_indexicon_greymoor_up.dds" },
	markarth = { id=1207, icon="esoui/art/treeicons/tutorial_indexicon_markarth_up.dds" },
	blackreach_arkthzand_cavern = { id=1208, icon="esoui/art/treeicons/tutorial_indexicon_markarth_up.dds" },
	blackreach_greymoor_caverns = { id=1161, icon="esoui/art/treeicons/tutorial_indexicon_greymoor_up.dds" },
	blackwood = { id=1261, icon="/esoui/art/icons/heraldrycrests_misc_tree_01.dds" },
	deadlands = { id=1286, icon="esoui/art/treeicons/tutorial_idexicon_deadlands_up.dds" },
	highisle = { id=1318, icon="/esoui/art/treeicons/store_indexicon_vanitypets_up.dds" },
	galen_yffelon = { id=1383, icon="esoui/art/treeicons/tutorial_idexicon_firesong_up.dds" },
	apocrypha = { id=1413, icon="esoui/art/icons/heraldrycrests_daedra_hermaeusmora_01.dds" },
	telvanni_peninsula = { id=1414, icon="esoui/art/icons/heraldrycrests_daedra_hermaeusmora_01.dds" },
	west_weald = { id=1443, icon="/esoui/art/treeicons/tutorial_indexicon_scribing_up.dds" },
	solstice = { id=1502, icon="/esoui/art/icons/u46_coin_wormcult.dds" },
}

local researchableTraits = {
	[ITEM_TRAIT_TYPE_WEAPON_POWERED] = 23203, --Chysolite
	[ITEM_TRAIT_TYPE_WEAPON_CHARGED] = 23204, --Amethyst
	[ITEM_TRAIT_TYPE_WEAPON_PRECISE] = 4486, --Ruby
	[ITEM_TRAIT_TYPE_WEAPON_INFUSED] = 810, --Jade
	[ITEM_TRAIT_TYPE_WEAPON_DEFENDING] = 813, --Turquoise
	[ITEM_TRAIT_TYPE_WEAPON_TRAINING] = 23165, --Carnelian
	[ITEM_TRAIT_TYPE_WEAPON_SHARPENED] = 23149, --Fire Opal
	[ITEM_TRAIT_TYPE_WEAPON_DECISIVE] = 16291, --Citrine
	[ITEM_TRAIT_TYPE_WEAPON_NIRNHONED] = 56863, --Potent Nirncrux
	[ITEM_TRAIT_TYPE_ARMOR_STURDY] = 4456, --Quartz
	[ITEM_TRAIT_TYPE_ARMOR_IMPENETRABLE] = 23219, --Diamond
	[ITEM_TRAIT_TYPE_ARMOR_REINFORCED] = 30221, --Sardonyx
	[ITEM_TRAIT_TYPE_ARMOR_WELL_FITTED] = 23221, --Almandine
	[ITEM_TRAIT_TYPE_ARMOR_TRAINING] = 4442, --Emerald
	[ITEM_TRAIT_TYPE_ARMOR_INFUSED] = 30219, --Bloodstone
	[ITEM_TRAIT_TYPE_ARMOR_PROSPEROUS] = 23171, --Garnet
	[ITEM_TRAIT_TYPE_ARMOR_DIVINES] = 23173, --Sapphire
	[ITEM_TRAIT_TYPE_ARMOR_NIRNHONED] = 56862, --Fortified Nirncrux
	[ITEM_TRAIT_TYPE_JEWELRY_ARCANE] = 135155, --Cobalt
	[ITEM_TRAIT_TYPE_JEWELRY_HEALTHY] = 135156, --Antimony
	[ITEM_TRAIT_TYPE_JEWELRY_ROBUST] = 135157, --Zinc
	[ITEM_TRAIT_TYPE_JEWELRY_TRIUNE] = 139409, --Dawn-Prism
	[ITEM_TRAIT_TYPE_JEWELRY_INFUSED] = 139411, --Aurbic Amber
	[ITEM_TRAIT_TYPE_JEWELRY_PROTECTIVE] = 139410, --Titanium
	[ITEM_TRAIT_TYPE_JEWELRY_SWIFT] = 139412, --Gilding Wax
	[ITEM_TRAIT_TYPE_JEWELRY_HARMONY] = 139413, --Dibellium
	[ITEM_TRAIT_TYPE_JEWELRY_BLOODTHIRSTY] = 139414 --Slaughterstone
}

-- M:New("test name", itemStyleId, achievementId, collectibleId, id, quality, hasChapters) To get the itemStyleId you need the link of an item in that style, to get the collectibleId you need the heavy head, to get the id you need the motif book (or axes motif minus 1)
local ARC = ITEM_FUNCTIONAL_QUALITY_ARCANE
local LEG = ITEM_FUNCTIONAL_QUALITY_LEGENDARY
local M = TB_Data_Motif
local motifs = {
	[1] = M:New("High Elf", 7, 1030, 2872, 16424, ARC, false),
	[2] = M:New("Dark Elf", 4, 1030, 2094, 27245, ARC, false),
	[3] = M:New("Wood Elf", 8, 1030, 1734, 16428, ARC, false),
	[4] = M:New("Nord", 5, 1030, 2340, 27244, ARC, false),
	[5] = M:New("Breton", 1, 1030, 1598, 16425, ARC, false),
	[6] = M:New("Redguard", 2, 1030, 2006, 16427, ARC, false),
	[7] = M:New("Khajiit", 9, 1030, 3093, 44698, ARC, false),
	[8] = M:New("Orc", 3, 1030, 1791, 16426, ARC, false),
	[9] = M:New("Argonian", 6, 1030, 2562, 27246, ARC, false),
	[10] = M:New("Imperial", 34, 1043, 3187, 54868, LEG, false),
	[11] = M:New("Ancient Elf", 15, 1043, 2684, 51638, nil, false),
	[12] = M:New("Barbaric", 17, 1043, 2399, 51565, nil, false),
	[13] = M:New("Primal", 19, 1043, 1614, 51345, nil, false),
	[14] = M:New("Daedric", 20, 1043, 2527, 51688, nil, false),
	[15] = M:New("Dwemer", 14, 1144, 3008, 57572),
	[16] = M:New("Glass", 28, 1319, 3556, 64669),
	[17] = M:New("Xivkyn", 29, 1181, 3429, 57834),
	[18] = M:New("Akaviri", 33, 1318, 2956, 57590),
	[19] = M:New("Mercenary", 26, 1348, 3681, 64715),
	[20] = M:New("Yokudan", 35, 1713, 3335, 57605),
	[21] = M:New("Ancient Orc", 22, 1341, 3467, 69527),
	[22] = M:New("Trinimac", 21, 1411, 3781, 71550),
	[23] = M:New("Malacath", 13, 1412, 3788, 71566),
	[24] = M:New("Outlaw", 47, 1417, 3288, 71522),
	[25] = M:New("Aldmeri Dominion", 25, 1415, 3609, 71688),
	[26] = M:New("Daggerfall Covenant", 23, 1416, 3665, 71704),
	[27] = M:New("Ebonheart Pact", 24, 1414, 3570, 71720),
	[28] = M:New("Ra Gada", 44, 1797, 3928, 71672),
	[29] = M:New("Soul Shriven", 30, 1418, 3505, 71765, LEG, false),
	[30] = M:New("Morag Tong", 43, 1933, 3924, 73838),
	[31] = M:New("Skinchanger", 42, 1676, 4087, 73854),
	[32] = M:New("Abah's Watch", 41, 1422, 3940, 74539),
	[33] = M:New("Thieves Guild", 11, 1423, 3838, 74555),
	[34] = M:New("Assassins League", 46, 1424, 3415, 76878),
	[35] = M:New("Dro-M'Athra", 45, 1659, 3865, 74652),
	[36] = M:New("Dark Brotherhood", 12, 1661, 3746, 82054),
	[37] = M:New("Ebony", 40, 1798, 4135, 75228),
	[38] = M:New("Draugr", 31, 1715, 2784, 76894),
	[39] = M:New("Minotaur", 39, 1662, 4011, 82071),
	[40] = M:New("Order Hour", 16, 1660, 4059, 82087),
	[41] = M:New("Celestial", 27, 1714, 3342, 82006),
	[42] = M:New("Hollowjack", 59, 1545, 4258, 82022),
	[43] = M:New("Grim Harlequin", 58, nil, 4106, 82053, LEG, false),
	[44] = M:New("Silken Ring", 56, 1796, 3761, 114967),
	[45] = M:New("Mazzatun", 57, 1795, 4162, 114951),
	[46] = M:New("Frostcaster", 53, nil, 4315, 96954, LEG, false),
	[47] = M:New("Buoyant Armiger", 52, 1934, 4482, 121316),
	[48] = M:New("Ashlander", 54, 1932, 4528, 124679),
	[49] = M:New("Militant Ordinator", 50, 1935, 4491, 121348),
	[50] = M:New("Telvanni", 51, 2023, 4442, 121332),
	[51] = M:New("Hlaalu", 49, 2021, 4402, 129994),
	[52] = M:New("Redoran", 48, 2022, 4421, 130010),
	[53] = M:New("Tsaesci", 38, nil, 4361, 132532, LEG, false),
	[54] = M:New("Bloodforge", 61, 2098, 4581, 132533),
	[55] = M:New("Dreadhorn", 62, 2097, 4622, 132565),
	[56] = M:New("Apostle", 65, 2044, 4948, 132549),
	[57] = M:New("Ebonshadow", 66, 2045, 4962, 132581),
	[58] = M:New("Fang Lair", 69, 2190, 5339, 134755),
	[59] = M:New("Scalecaller", 70, 2189, 5404, 134771),
	[60] = M:New("Worm Cult", 55, 2120, 4215, 134739),
	[61] = M:New("Psijic", 71, 2186, 5318, 137851),
	[62] = M:New("Sapiarch", 72, 2187, 5533, 137920),
	[63] = M:New("Dremora", 74, 2188, 4653, 140444),
	[64] = M:New("Pyandonean", 75, 2285, 5486, 140428),
	[65] = M:New("Huntsman", 77, 2317, 5782, 140462),
	[66] = M:New("Silver Dawn", 78, 2318, 5814, 140478),
	[67] = M:New("Welkynar", 73, 2319, 5666, 140496),
	[68] = M:New("Honor Guard", 80, 2359, 6125, 142186),
	[69] = M:New("Dead-Water", 79, 2360, 5940, 142202),
	[70] = M:New("Elder Argonian", 81, 2361, 5972, 142218),
	[71] = M:New("Coldsnap", 82, 2503, 6332, 147666),
	[72] = M:New("Meridian", 83, 2504, 6300, 147682),
	[73] = M:New("Anequina", 84, 2505, 6542, 147698),
	[74] = M:New("Pellitine", 85, 2506, 6510, 147714),
	[75] = M:New("Sunspire", 86, 2507, 6875, 147730),
	[76] = M:New("Dragonguard", 92, 2630, 7026, 156555),
	[77] = M:New("Stags of Z'en", 89, 2629, 6853, 156573),
	[78] = M:New("Moongrave Fane", 93, 2628, 7145, 156590),
	[79] = M:New("Refabricated", 60, 2024, 4557, 130026),
	[80] = M:New("Shield of Senchal", 95, 2750, 7245, 156627),
	[81] = M:New("New Moon Priest", 94, 2748, 7184, 156608),
	[82] = M:New("Icereach Coven", 97, 2747, 7470, 157517),
	[83] = M:New("Pyre Watch", 98, 2749, 7540, 158291),
	[84] = M:New("Blackreach Vanguard", 100, 2757, 7701, 160493),
	[85] = M:New("Greymoor", 101, 2761, 7831, 160542),
	[86] = M:New("Sea Giant", 102, 2762, 7866, 160559),
	[87] = M:New("Ancestral Nord", 103, 2763, 7899, 160576),
	[88] = M:New("Ancestral Orc", 105, 2776, 7966, 160610),
	[89] = M:New("Ancestral High Elf", 104, 2773, 7934, 160593),
	[90] = M:New("Thorn Legion", 106, 2849, 8231, 166972),
	[91] = M:New("Hazardous Alchemy", 107, 2850, 8263, 166989),
	[92] = M:New("Ancestral Akaviri", 108, 2903, 8390, 167174),
	[93] = M:New("Ancestral Breton", 109, 2904, 8422, 167190),
	[94] = M:New("Ancestral Reach", 110, 2905, 8476, 167270),
	[95] = M:New("Nighthollow", 111, 2926, 8553, 167943),
	[96] = M:New("Arkthzand Armory", 112, 2938, 8589, 167960),
	[97] = M:New("Wayward Guardian", 113, 2998, 8621, 167977),
	[98] = M:New("House Hexos", 114, 2959, 8699, 170131),
	[99] = M:New("Waking Flame", 117, 2991, 8963, 171580),
	[100] = M:New("True-Sworn", 116, 2984, 8922, 171551),
	[101] = M:New("Ivory Brigade", 121, 3001, 9166, 171895),
	[102] = M:New("Sul-Xan", 122, 3002, 9198, 171912),
	[103] = M:New("Black Fin Legion", 120, 3000, 9131, 171878),
	[104] = M:New("Ancient Daedric", 119, 2999, 9092, 171858),
	[105] = M:New("Crimson Oath", 123, 3094, 9473, 176057),
	[106] = M:New("Silver Rose", 124, 3097, 9534, 178504),
	[107] = M:New("Annihilarch's Chosen", 125, 3098, 9593, 178528),
	[108] = M:New("Fargrave Guardian", 126, 3220, 9687, 178706),
--	[109] = M:New("Flame Awoken", , ),
	[110] = M:New("Dreadsails", 128, 3228, 9914, 181661),
	[111] = M:New("Ascendant Order", 129, 3229, 9946, 181678),
	[112] = M:New("Syrabanic Marine", 130, 3258, 10074, 182520),
	[113] = M:New("Steadfast Society", 131, 3259, 10106, 182537),
	[114] = M:New("Systres Guardian", 132, 3260, 10138, 182554),
	[115] = M:New("Y'ffre's Will", 135, 3422, 10443, 187728),
	[116] = M:New("Drowned Mariner", 136, 3423, 10478, 187762),
	[117] = M:New("Firesong", 138, 3464, 10774, 188307),
	[118] = M:New("House Mornard", 139, 3465, 10806, 188324),
	[119] = M:New("Blessed Inheritor", 141, 3547, 10967, 190906),
	[120] = M:New("Scribes of Mora", 140, 3546, 10935, 190889),
	[121] = M:New("Clan Dreamcarver", 142, 3667, 11262, 194492),
	[122] = M:New("Dead Keeper", 143, 3668, 11295, 194513),
	[123] = M:New("Kindred's Concord", 144, 3669, 11329, 194540),
	[124] = M:New("The Recollection", 145, 3921, 11928, 203182),
	[125] = M:New("Blind Path Cultist", 146, 3922, 11964, 203214),
	[126] = M:New("Shardborn", 147, 3923, 12074, 203360),
	[127] = M:New("West Weald Legion", 148, 3924, 12106, 203473),
	[128] = M:New("Lucent Sentinel", 149, 3925, 12138, 203492),
	[129] = M:New("Hircine Bloodhunter", 151, nil, 12275, 203834, LEG, false),
	[130] = M:New("Exile's Revenge", 153, 4159, 12879, 211054),
	[131] = M:New("Militant Monk", 154, 4160, 12911, 211071),
	[132] = M:New("Stirk Fellowship", 155, 4240, 13119, 212084),
	[133] = M:New("Coldharbour Dominator", 156, 4241, 13151, 212101),
	[134] = M:New("Tide-Born", 157, 4242, 13183, 212118),
	[135] = M:New("Black Soul Gem", 158, 4289, 13310, 212424),
	[136] = M:New("Voskrona Guardian", 159, 4290, 13342, 212441),
}

--Chapter to motif book order, matches achievement
local chapterOrder = {
	[ITEM_STYLE_CHAPTER_AXES]=1,
	[ITEM_STYLE_CHAPTER_BELTS]=2,
	[ITEM_STYLE_CHAPTER_BOOTS]=3,
	[ITEM_STYLE_CHAPTER_BOWS]=4,
	[ITEM_STYLE_CHAPTER_CHESTS]=5,
	[ITEM_STYLE_CHAPTER_DAGGERS]=6,
	[ITEM_STYLE_CHAPTER_GLOVES]=7,
	[ITEM_STYLE_CHAPTER_HELMETS]=8,
	[ITEM_STYLE_CHAPTER_LEGS]=9,
	[ITEM_STYLE_CHAPTER_MACES]=10,
	[ITEM_STYLE_CHAPTER_SHIELDS]=11,
	[ITEM_STYLE_CHAPTER_SHOULDERS]=12,
	[ITEM_STYLE_CHAPTER_STAVES]=13,
	[ITEM_STYLE_CHAPTER_SWORDS]=14
}

--Base item id of first trait of first item
local traitLinks = {
	[CRAFTING_TYPE_BLACKSMITHING] = {
		orig={[1]=45018,[2]=45025},
		nirn={[1]=56026,[2]=56038}
	},
	[CRAFTING_TYPE_CLOTHIER] = {
		orig={[1]=45032,[2]=45041},
		nirn={[1]=56045,[2]=56053}
	},
	[CRAFTING_TYPE_WOODWORKING] = {
		orig={[1]=45040,[2]=45048},
		nirn={[1]=56033,[2]=56060}
	},
	[CRAFTING_TYPE_JEWELRYCRAFTING] = {
		neck={[1]=54511,[2]=139398},
		ring={[1]=54507,[2]=139392}
	}
}

local L = TB_Data_SetLocation
-- id == Go to set location > create > Axe > Link in chat from large tool tip
-- Or data site and find the top listed set axe
local sets = {
	[1] = {id=43871, traits=2, locations={[1]={zone=L:New(zones.stonefalls)},[2]={zone=L:New(zones.glenumbra)},[3]={zone=L:New(zones.auridon)}}, test="Ashen Grip"},
	[2] = {id=46499, traits=2, locations={[1]={zone=L:New(zones.stonefalls)},[2]={zone=L:New(zones.glenumbra)},[3]={zone=L:New(zones.auridon)}}, test="Death's Wind"},
	[3] = {id=47265, traits=2, locations={[1]={zone=L:New(zones.stonefalls)},[2]={zone=L:New(zones.glenumbra)},[3]={zone=L:New(zones.auridon)}}, test="Night's Silence"},

	[4] = {id=50708, traits=3, locations={[1]={zone=L:New(zones.deshaan)},[2]={zone=L:New(zones.stormhaven)},[3]={zone=L:New(zones.grahtwood)}}, test="Torug's Pact"},
	[5] = {id=43807, traits=3, locations={[1]={zone=L:New(zones.deshaan)},[2]={zone=L:New(zones.stormhaven)},[3]={zone=L:New(zones.grahtwood)}}, test="Twilight's Embrace"},
	[6] = {id=43827, traits=3, locations={[1]={zone=L:New(zones.deshaan)},[2]={zone=L:New(zones.stormhaven)},[3]={zone=L:New(zones.grahtwood)}}, test="Armor of the Seducer"},

	[7] = {id=69949, traits=3, locations={[1]={zone=L:New(zones.wrothgar)}}, test="Trial by Fire"},
	[8] = {id=121585, traits=3, locations={[1]={zone=L:New(zones.vvardenfell)}}, test="Assassin's Guile"},

	[9] = {id=43847, traits=4, locations={[1]={zone=L:New(zones.shadowfen)},[2]={zone=L:New(zones.rivenspire)},[3]={zone=L:New(zones.greenshade)}}, test="Magnus' Gift"},
	[10] = {id=43995, traits=4, locations={[1]={zone=L:New(zones.shadowfen)},[2]={zone=L:New(zones.rivenspire)},[3]={zone=L:New(zones.greenshade)}}, test="Hist Bark"},
	[11] = {id=43819, traits=4, locations={[1]={zone=L:New(zones.shadowfen)},[2]={zone=L:New(zones.rivenspire)},[3]={zone=L:New(zones.greenshade)}}, test="Whitestrake's Retribution"},

	[12] = {id=43831, traits=5, locations={[1]={zone=L:New(zones.eastmarch)},[2]={zone=L:New(zones.alikrdesert)},[3]={zone=L:New(zones.malabaltor)}}, test="Vampire's Kiss"},
	[13] = {id=44013, traits=5, locations={[1]={zone=L:New(zones.eastmarch)},[2]={zone=L:New(zones.alikrdesert)},[3]={zone=L:New(zones.malabaltor)}}, test="Song of Lamae"},
	[14] = {id=44019, traits=5, locations={[1]={zone=L:New(zones.eastmarch)},[2]={zone=L:New(zones.alikrdesert)},[3]={zone=L:New(zones.malabaltor)}}, test="Alessia's Bulwark"},

	[15] = {id=60280, traits=5, locations={[1]={zone=L:New(zones.imperialcity)}}, test="Noble's Conquest"},
	[16] = {id=71795, traits=5, locations={[1]={zone=L:New(zones.hewsbane)}}, test="Tava's Favor"},
	[17] = {id=75397, traits=5, locations={[1]={zone=L:New(zones.goldcoast)}}, test="Kvatch Gladiator"},

	[18] = {id=43859, traits=6, locations={[1]={zone=L:New(zones.therift)},[2]={zone=L:New(zones.bangkorai)},[3]={zone=L:New(zones.reapersmarch)}}, test="Night Mother's Gaze"},
	[19] = {id=44001, traits=6, locations={[1]={zone=L:New(zones.therift)},[2]={zone=L:New(zones.bangkorai)},[3]={zone=L:New(zones.reapersmarch)}}, test="Willow's Path"},
	[20] = {id=44007, traits=6, locations={[1]={zone=L:New(zones.therift)},[2]={zone=L:New(zones.bangkorai)},[3]={zone=L:New(zones.reapersmarch)}}, test="Hunding's Rage"},

	[21] = {id=69606, traits=6, locations={[1]={zone=L:New(zones.wrothgar)}}, test="Law of Julianos"},
	[22] = {id=122285, traits=6, locations={[1]={zone=L:New(zones.vvardenfell)}}, test="Shacklebreaker"},

	[23] = {id=60618, traits=7, locations={[1]={zone=L:New(zones.imperialcity)}}, test="Redistributor"},
	[24] = {id=72145, traits=7, locations={[1]={zone=L:New(zones.hewsbane)}}, test="Clever Alchemist"},
	[25] = {id=75747, traits=7, locations={[1]={zone=L:New(zones.goldcoast)}}, test="Varen's Legacy"},

	[26] = {id=121912, traits=8, locations={[1]={zone=L:New(zones.vvardenfell)}}, test="Daedric Trickery"},
	[27] = {id=53757, traits=8, locations={[1]={zone=L:New(zones.earthforge)}}, test="Kagrenac's Hope"}, --The Rift > Fighters Guild > The Earth Forge
	[28] = {id=52995, traits=8, locations={[1]={zone=L:New(zones.earthforge)}}, test="Orgnum's Scales"}, --The Rift > Fighters Guild > The Earth Forge > Pressure Room III
	[29] = {id=44049, traits=8, locations={[1]={zone=L:New(zones.eyevea)}}, test="Eyes of Mara"}, --Mages Guild > Eyevea
	[30] = {id=40259, traits=8, locations={[1]={zone=L:New(zones.eyevea)}}, test="Shalidor's Curse"}, --Mages Guild > Eyevea
	[31] = {id=43965, traits=8, locations={[1]={zone=L:New(zones.coldharbour)}}, test="Oblivion's Foe"},
	[32] = {id=43971, traits=8, locations={[1]={zone=L:New(zones.coldharbour)}}, test="Spectre's Eye"},
	[33] = {id=54787, traits=8, locations={[1]={zone=L:New(zones.craglorn)}}, test="Way of the Arena"},

	[34] = {id=58153, traits=9, locations={[1]={zone=L:New(zones.craglorn)}}, test="Twice-Born Star"},
	[35] = {id=60973, traits=9, locations={[1]={zone=L:New(zones.imperialcity)}}, test="Armor Master"},
	[36] = {id=70642, traits=9, locations={[1]={zone=L:New(zones.wrothgar)}}, test="Morkuldin"},
	[37] = {id=72502, traits=9, locations={[1]={zone=L:New(zones.hewsbane)}}, test="Eternal Hunt"},
	[38] = {id=76120, traits=9, locations={[1]={zone=L:New(zones.goldcoast)}}, test="Pelinal's Wrath"},

	[39] = {id=130370, traits=2, locations={[1]={zone=L:New(zones.clockwork)}}, test="Innate Axiom"},
	[40] = {id=130720, traits=4, locations={[1]={zone=L:New(zones.brassfort)}}, test="Fortified Brass"},
	[41] = {id=131070, traits=6, locations={[1]={zone=L:New(zones.clockwork)}}, test="Mechanical Acuity"},

	[42] = {id=135717, traits=3, locations={[1]={zone=L:New(zones.summerset)}}, test="Adept Rider"},
	[43] = {id=136067, traits=6, locations={[1]={zone=L:New(zones.artaeum)}}, test="Sload's Semblance"},
	[44] = {id=136417, traits=9, locations={[1]={zone=L:New(zones.summerset)}}, test="Nocturnal's Favor"},

	[45] = {id=143161, traits=2, locations={[1]={zone=L:New(zones.murkmire)}}, test="Naga Shaman"},
	[46] = {id=143531, traits=4, locations={[1]={zone=L:New(zones.murkmire)}}, test="Might of the Lost Legion"},
	[47] = {id=142791, traits=7, locations={[1]={zone=L:New(zones.murkmire)}}, test="Grave-Stake Collector"},

	[48] = {id=148688, traits=3, locations={[1]={zone=L:New(zones.elsweyr_north)}}, test="Vastarie's Tutelage"},
	[49] = {id=148318, traits=5, locations={[1]={zone=L:New(zones.elsweyr_north)}}, test="Senche-raht's Grit"},
	[50] = {id=147948, traits=8, locations={[1]={zone=L:New(zones.elsweyr_north)}}, test="Coldharbour's Favorite"},

	[51] = {id=155778, traits=3, locations={[1]={zone=L:New(zones.elsweyr_south)}}, test="Ancient Dragonguard"},
	[52] = {id=155404, traits=3, locations={[1]={zone=L:New(zones.elsweyr_south)}}, test="Daring Corsair"},
	[53] = {id=156152, traits=9, locations={[1]={zone=L:New(zones.elsweyr_south)}}, test="New Moon Acolyte"},

	[54] = {id=158316, traits=3, locations={[1]={zone=L:New(zones.cyrodiil)}}, test="Critical Riposte"}, --Located in Vlasterus
	[55] = {id=158690, traits=3, locations={[1]={zone=L:New(zones.cyrodiil)}}, test="Unchained Aggressor"}, --Located in Bruma
	[56] = {id=159064, traits=3, locations={[1]={zone=L:New(zones.cyrodiil)}}, test="Dauntless Combatant"}, --Located in Cropsford

	[57] = {id=161221, traits=5, locations={[1]={zone=L:New(zones.greymoor)}}, test="Stuhn's Favor"},
	[58] = {id=161595, traits=7, locations={[1]={zone=L:New(zones.greymoor)}}, test="Dragon's Appetite"},
	[59] = {id=163057, traits=3, locations={[1]={zone=L:New(zones.blackreach_greymoor_caverns)}}, test="Spell Parasite"},

	[60] = {id=168747, traits=9, locations={[1]={zone=L:New(zones.blackreach_arkthzand_cavern)}}, test="Aetherial Ascension"},
	[61] = {id=168373, traits=6, locations={[1]={zone=L:New(zones.markarth)}}, test="Legacy of Karth"},
	[62] = {id=167999, traits=3, locations={[1]={zone=L:New(zones.markarth)}}, test="Red Eagle's Fury"},

	[63] = {id=173203, traits=5, locations={[1]={zone=L:New(zones.blackwood)}}, test="Diamond's Victory"},
	[64] = {id=172829, traits=7, locations={[1]={zone=L:New(zones.blackwood)}}, test="Heartland Conqueror"},
	[65] = {id=172455, traits=3, locations={[1]={zone=L:New(zones.blackwood)}}, test="Hist Whisperer"},

	[66] = {id=178806, traits=3, locations={[1]={zone=L:New(zones.deadlands)}}, test="Wretched Vitality"},
	[67] = {id=179180, traits=7, locations={[1]={zone=L:New(zones.deadlands)}}, test="Deadlands Demolisher"},
	[68] = {id=179554, traits=5, locations={[1]={zone=L:New(zones.deadlands)}}, test="Iron Flask"},
	
	[69] = {id=184771, traits=3, locations={[1]={zone=L:New(zones.highisle)}}, test="Order's Wrath"},
	[70] = {id=185151, traits=5, locations={[1]={zone=L:New(zones.highisle)}}, test="Serpent's Disdain"},
	[71] = {id=185531, traits=7, locations={[1]={zone=L:New(zones.highisle)}}, test="Druid's Braid"},

	[72] = {id=191612, traits=3, locations={[1]={zone=L:New(zones.galen_yffelon)}}, test="Old Growth Brewer"},
	[73] = {id=191992, traits=5, locations={[1]={zone=L:New(zones.galen_yffelon)}}, test="Claw of the Forest Wraith"},
	[74] = {id=191232, traits=7, locations={[1]={zone=L:New(zones.galen_yffelon)}}, test="Chimera's Rebuke"},

	[75] = {id=194942 , traits=3, locations={[1]={zone=L:New(zones.telvanni_peninsula)}}, test="Telvanni Efficiency"},
	[76] = {id=194562 , traits=5, locations={[1]={zone=L:New(zones.telvanni_peninsula)}}, test="Shattered Fate"},
	[77] = {id=195322 , traits=7, locations={[1]={zone=L:New(zones.apocrypha)}}, test="Seeker Synthesis"},

	[78] = {id=205773 , traits=5, locations={[1]={zone=L:New(zones.west_weald)}}, test="Highland Sentinel"},
	[79] = {id=205393 , traits=3, locations={[1]={zone=L:New(zones.west_weald)}}, test="Tharriker’s Strike"},
	[80] = {id=206153 , traits=7, locations={[1]={zone=L:New(zones.west_weald)}}, test="Threads of War"},

	[82] = {id=215099 , traits=3, locations={[1]={zone=L:New(zones.solstice)}}, test="Shared Burden"},
	[81] = {id=215479 , traits=5, locations={[1]={zone=L:New(zones.solstice)}}, test="Tide-Born Wildstalker"},
	[83] = {id=215859 , traits=7, locations={[1]={zone=L:New(zones.solstice)}}, test="Fellowship's Fortitude"},
}

TB_Data = ZO_Object:Subclass()
function TB_Data:New(...)
	local object = ZO_Object.New(self)
	object:Initialize(...)
	return object
end
function TB_Data:GetTraitLinkID(craftingSkillType, researchLineIndex, traitIndex)
	--Rather than storing 306 unique ids
	local researchLineSplit = TraitBuddy.ui:GetResearchSplit()
	local split = researchLineSplit[craftingSkillType]
	local part = 1
	local start = 1
	local id = 0
	if researchLineIndex >= split then
		--Second section, normally armour
		start = split
		part = 2
	end
	if traitIndex==9 then
		id = traitLinks[craftingSkillType].nirn[part]+researchLineIndex-start
		--All nirns are sequential except the last 2 in light armour
		if craftingSkillType==CRAFTING_TYPE_CLOTHIER and part==1 and researchLineIndex>=split-2 then
			id=id+1
		end
	else
		local base = traitLinks[craftingSkillType].orig[part]
		--All are sequential except the last 2 in light armour and the first one in wood is odd
		if craftingSkillType==CRAFTING_TYPE_CLOTHIER and part==1 and researchLineIndex>=split-2 then
			base=base+1
		elseif craftingSkillType==CRAFTING_TYPE_WOODWORKING and part==1 and researchLineIndex>1 then
			base=base+8
		end
		id = 35*traitIndex-35+base+researchLineIndex-start
	end
	return id
end
function TB_Data:GetJewelryTraitLinkID(researchLineIndex, traitIndex)
	--Rather than storing 18 unique ids
	local id = 0
	local part = 1
	if traitIndex >= 4 then
		part = 2
	end
	if researchLineIndex==1 then
		-- Pewter Ring (54512 to 54514, 139402 to 139407)
		id = traitLinks[CRAFTING_TYPE_JEWELRYCRAFTING].ring[part]+traitIndex
	else
		-- Pewter Necklace (54508 to 54510, 139396 to 139401)
		id = traitLinks[CRAFTING_TYPE_JEWELRYCRAFTING].neck[part]+traitIndex
	end
	if traitIndex==1 or traitIndex==5 then
		id = id+1
	elseif traitIndex==2 or traitIndex==6 then
		id = id-1
	end
	return id
end
function TB_Data:GetResearchableTraitMaterials()
	return researchableTraits
end
function TB_Data:IsResearchableTrait(traitType)
	if not traitType then return false end
	return (researchableTraits[traitType] ~= nil)
end
function TB_Data:GetMotif(index)
	return motifs[index]
end
function TB_Data:GetMotifs()
	return motifs
end
function TB_Data:GetNumMotifs()
	local numMotifs = NonContiguousCount(motifs)
	local numChapters = self:GetNumChapters()
	local numChaptersTotal = 0
	for order,motif in pairs(motifs) do
		if motif:HasChapters() then
			numChaptersTotal = numChaptersTotal + numChapters
		end
	end
	return numMotifs, numChaptersTotal
end
function TB_Data:GetNumChapters()
	return NonContiguousCount(chapterOrder)
end
function TB_Data:GetMotifByItemStyleId(itemStyleId)
	for order,motif in pairs(motifs) do
		if motif:ItemStyleId()==itemStyleId then
			return motif
		end
	end
	return nil
end
function TB_Data:GetChapterOrder(chapterIndex)
	return chapterOrder[chapterIndex] or ITEM_STYLE_CHAPTER_ALL
end
function TB_Data:GetMotifStyle(itemLink)
	--Returns: itemStyleId, chapter, motifOrder, chapterOrder
	local itemId = select(4, ZO_LinkHandler_ParseLink(itemLink))
	itemId = tonumber(itemId)
	for order,motif in pairs(motifs) do
		if motif:HasChapters() then
			for chapterStyle,chapterOrder in pairs(chapterOrder) do
				if itemId==motif:ChapterId(chapterOrder) then
					return motif:ItemStyleId(), chapterStyle, order, chapterOrder
				end
			end
		else
			if itemId==motif:Id() then
				return motif:ItemStyleId(), ITEM_STYLE_CHAPTER_ALL, order, nil
			end
		end
	end
	return 0, ITEM_STYLE_CHAPTER_ALL, nil, nil
end
function TB_Data:GetSets()
	return sets
end
function TB_Data:GetSet(index)
	return sets[index]
end
function TB_Data:TestMotifs()
	-- Test the motifs for various things /script d(TraitBuddy.data:TestMotifs())
	-- Store the info in /zgoo TraitBuddy.data > GetMotifs > Issues
	local issues = 0
	for order,motif in pairs(motifs) do
		motif:Check()
		if motif:HasIssues() then
			issues = issues + 1
			for k,issue in ipairs(motif:Issues()) do
				d(sf("Check %s %s", motif:Order(), issue))
			end
		end
	end
	d(sf("Motif Test: Issues with %s motif(s).", issues))
end
function TB_Data:TestSets()
	local okay = 0
	local checkout = {}
	local STYLE_BRETON = 1
	for i,set in pairs(sets) do
		local itemLink = ZO_LinkHandler_CreateLink("",nil,ITEM_LINK_TYPE,set.id,30,1,0,0,0,0,0,0,0,0,0,0,0,0,STYLE_BRETON,0,0,0,10000,0)
		local _, setName, _, _, _, _ = GetItemLinkSetInfo(itemLink, false)
		if setName == set.test then
			okay = okay + 1
		else
			checkout[#checkout+1] = {name = setName, test = set.test}
		end
	end
	d(sf("Sets Test: %s/%s sets are okay", okay, #sets))
	for i,set in pairs(checkout) do
		d(sf("Check set %s/%s", set.name, set.test))
	end
end
function TB_Data:TestMotifsDump()
	for itemStyleIndex = 1, GetNumValidItemStyles() do
		local itemStyleId = GetValidItemStyleId(itemStyleIndex)
		if itemStyleId > 0 then
			local styleItemLink = GetItemStyleMaterialLink(itemStyleId, LINK_STYLE_DEFAULT) or ""
			local itemId = select(4, ZO_LinkHandler_ParseLink(styleItemLink))
			itemId = tonumber(itemId) or 0
			d(sf("Id %s %s %s itemId %d", itemStyleId, GetItemStyleName(itemStyleId), styleItemLink, itemId))
		end
	end
end
function TB_Data:TestMotifsMissing()
	d("Checking for missing motifs...")
	local lookat = 0
	local universal = 36
	for itemStyleIndex = 1, GetNumValidItemStyles() do
		local itemStyleId = GetValidItemStyleId(itemStyleIndex)
		if itemStyleId > 0 then
			local motif = self:GetMotifByItemStyleId(itemStyleId)
			if not motif then
				local styleItemLink = GetItemStyleMaterialLink(itemStyleId, LINK_STYLE_DEFAULT)
				local materialItemId = select(4, ZO_LinkHandler_ParseLink(styleItemLink))
				materialItemId = tonumber(materialItemId)
				if materialItemId ~= nil and itemStyleId ~= universal then lookat = lookat + 1 end
				d(sf("Id %s %s %s", itemStyleId, GetItemStyleName(itemStyleId), styleItemLink))
			end
		end
	end
	d(sf("Done! %s to look at", lookat))
end
function TB_Data:TestLoreBooks()
	-- /script d(TraitBuddy.data:TestLoreBooks())
	local order = self:GetChapterOrder(ITEM_STYLE_CHAPTER_AXES)
	local motif = self:GetMotif(15) -- [15] = M:New("Dwemer", 14, 1144, 3008, 57572),
	d(motif:ChapterLink(order))
	d(motif:AchievementLink())
	-- local collectionId = GetAchievementLinkedBookCollectionId(1144)
	local categoryIndex, collectionIndex = GetLoreBookCollectionIndicesFromCollectionId(GetAchievementLinkedBookCollectionId(motif:AchievementId()))
	local title, icon, known, bookId = GetLoreBookInfo(categoryIndex, collectionIndex, order) -- Dwemer axe |H1:book:2857|h|h
	d(sf("title:%s known:%s bookId:%s", title, tostring(known), bookId))
end
function TB_Data:TestLocation()
	for mapIndex = 1, GetNumMaps() do
		local name, mapType, mapContentType, zoneId, description = GetMapInfo(mapIndex)
		d(sf("%s MapType %s Content Type %s ZoneId %s", name, mapType, mapContentType, zoneId))
	end

	local zoneIndex = GetCurrentMapZoneIndex()
	local zoneId = GetZoneId(zoneIndex)
	d("Current zone:")
	d(sf("By index %s index:%s", GetZoneNameByIndex(zoneIndex), zoneIndex))
	d(sf("By Id %s id:%s", GetZoneNameById(zoneId), zoneId))
end
function TB_Data:TestPatterns()
	d("TraitBuddy DEBUG: TestPatterns()")
	--[[
	* GetSmithingPatternInfo(*luaindex* patternIndex, *luaindex:nilable* materialIndexOverride, *integer:nilable* materialQuanityOverride, *integer:nilable* styleOverride, *[ItemTraitType|#ItemTraitType]:nilable* traitTypeOverride)
	** Returns: *string* patternName, *string* baseName, *textureName* icon, *integer* numMaterials, *integer* numTraitsRequired, *integer* numTraitsKnown, *[ItemFilterType|#ItemFilterType]* resultItemFilterType

	* GetSmithingPatternInfoForItemId(*integer* itemId, *integer* materialItemId, *[TradeskillType|#TradeskillType]* craftingSkillType)
	** Returns: *luaindex:nilable* patternIndex, *luaindex:nilable* materialIndex

	* GetSmithingPatternInfoForItemSet(*integer* itemTemplateId, *integer* itemSetId, *integer* materialItemId, *[ItemTraitType|#ItemTraitType]* traitType)
	** Returns: *luaindex:nilable* patternIndex, *luaindex:nilable* materialIndex, *integer:nilable* resultingItemId

	* GetSmithingPatternMaterialItemInfo(*luaindex* patternIndex, *luaindex* materialIndex)
	** Returns: *string* itemName, *textureName* icon, *integer* stack, *integer* sellPrice, *bool* meetsUsageRequirement, *[EquipType|#EquipType]* equipType, *integer* itemStyleId, *[ItemDisplayQuality|#ItemDisplayQuality]* displayQuality, *integer* itemInstanceId, *integer* skillRequirement, *integer* createsItemOfLevel, *bool* isChampionPoint

	]]--
	-- local patternIndex, materialIndex = GetSmithingPatternInfoForItemId(itemId, materialItemId, craftingSkillType)

	-- local patternIndex, materialIndex, resultingItemId = GetSmithingPatternInfoForItemSet(itemTemplateId, itemSetId, materialItemId, traitType)

	local numSmithingPatterns = GetNumSmithingPatterns()
	if numSmithingPatterns == 0 then
		d("Only works at a crafting station")
		return
	end
	local materialIndex = 1
	for patternIndex = 1, numSmithingPatterns do
		local patternName, _, _, numMaterials = GetSmithingPatternInfo(patternIndex)
		local _, _, stack = GetSmithingPatternMaterialItemInfo(patternIndex, materialIndex)
		d(sf("Pattern %s - %s - stack %s", patternIndex, patternName, stack))
	end
end
function TB_Data:Initialize_Motifs()
	for itemStyleIndex = 1, GetNumValidItemStyles() do
		local itemStyleId = GetValidItemStyleId(itemStyleIndex)
		if itemStyleId > 0 then
			local motif = self:GetMotifByItemStyleId(itemStyleId)
			if motif then
				local styleItemLink = GetItemStyleMaterialLink(itemStyleId, LINK_STYLE_DEFAULT)
				local icon = GetItemLinkInfo(styleItemLink)
				local itemId = select(4, ZO_LinkHandler_ParseLink(styleItemLink))
				motif:SetMaterial(itemId, icon)
			else
				--d(sf("TraitBuddy DEBUG: Could not Initialize motif itemStyleId:%s", itemStyleId))
			end
		end
	end
	for order,motif in pairs(motifs) do
		motif:SetOrder(order)
	end
end
function TB_Data:Initialize_Sets()
	local STYLE_BRETON = 1
	for i,set in pairs(sets) do
		local itemLink = ZO_LinkHandler_CreateLink("",nil,ITEM_LINK_TYPE,set.id,30,1,0,0,0,0,0,0,0,0,0,0,0,0,STYLE_BRETON,0,0,0,10000,0)
		local _, setName, _, _, _, _ = GetItemLinkSetInfo(itemLink, false)
		set.name = sf("%s", setName)
	end
end
function TB_Data:Initialize()
	self:Initialize_Motifs()
	if GetAPIVersion() < 100033 then
		--Remove content until it is active
		motifs[94] = nil
		motifs[96] = nil
		sets[60] = nil
		sets[61] = nil
		sets[62] = nil
	end
	-- check if these motifs exist
	if not motifs[120]:MaterialId() then
		motifs[120] = nil
	end
	if not motifs[119]:MaterialId() then
		motifs[119] = nil
	end

	self:Initialize_Sets()
end
