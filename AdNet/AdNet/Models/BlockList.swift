
@frozen
enum BlockList: String, CaseIterable {

  case oisd, goodbyeAdsStandard, goodbyeAdsYoutube

  var displayName: String {
    switch self {
    case .oisd               : return "OISD"
    case .goodbyeAdsStandard : return "GoodByeAds Standard"
    case .goodbyeAdsYoutube  : return "GoodByeAds Youtube"
    }
  }

  var downloadURL: String {
    switch self {
    case .oisd:
      return "https://abp.oisd.nl"
    case .goodbyeAdsStandard:
      return "https://raw.githubusercontent.com/jerryn70/GoodbyeAds/master/Formats/GoodbyeAds-AdBlock-Filter.txt"
    case .goodbyeAdsYoutube:
      return "https://raw.githubusercontent.com/jerryn70/GoodbyeAds/master/Formats/GoodbyeAds-YouTube-AdBlock-Filter.txt"
    }
  }

  var displayURL: String {
    switch self {
    case .oisd:
      return "oisd.nl"
    case .goodbyeAdsStandard, .goodbyeAdsYoutube:
      return "github.com/jerryn70/GoodbyeAds"
    }
  }

  static var defaultLists: [String: Bool] {
    var lists = BlockList.allCases.reduce(into: [String: Bool]()) { $0[$1.rawValue] = false }
    lists[BlockList.oisd.rawValue] = true
    return lists
  }
}
