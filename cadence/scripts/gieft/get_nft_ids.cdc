import "GiefMe"

// Get the NFT ids of a gieft owned by an address 
// @param owner: the owner of the gieft
// @param gieftID: the ID of the gieft
// @return: the nft ids of the gieft

pub fun main(owner: Address, gieftID: UInt64): [UInt64]? {
    var gieft: &GiefMe.Gieft{GiefMe.GieftPublic}? = nil
    gieft = getAccount(owner).getCapability(GiefMe.GiefMePublicPath).borrow<&GiefMe.GieftCollection{GiefMe.GieftCollectionPublic}>()?.borrowGieft(gieftID) ?? nil
    return gieft?.getNftIDs()
}