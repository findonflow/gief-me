import "GiefMe"

// Borrow a gieft from the gieft collection
// @param owner: the owner of the gieft
// @param gieftID: the ID of the gieft
// @return: the gieft reference

pub fun main(owner: Address): [UInt8]? {
    var gieft: &GiefMe.Gieft{GiefMe.GieftPublic}? = nil
    let ids = getAccount(owner).getCapability(GiefMe.GiefMePublicPath).borrow<&GiefMe.GieftCollection{GiefMe.GieftCollectionPublic}>()?.getGieftIDs()!
    return getAccount(owner).getCapability(GiefMe.GiefMePublicPath).borrow<&GiefMe.GieftCollection{GiefMe.GieftCollectionPublic}>()?.borrowGieft(ids[0])!?.password
}