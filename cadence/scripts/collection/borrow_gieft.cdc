import "GiefMe"

// Borrow a gieft from the gieft collection
// @param owner: the owner of the gieft
// @param gieftID: the ID of the gieft
// @return: the gieft reference

pub fun main(owner: Address, gieftID: UInt64): &GiefMe.Gieft{GiefMe.GieftPublic}? {
    var gieft: &GiefMe.Gieft{GiefMe.GieftPublic}? = nil
    gieft = getAccount(owner).getCapability(GiefMe.GiefMePublicPath).borrow<&GiefMe.GieftCollection{GiefMe.GieftCollectionPublic}>()?.borrowGieft(gieftID) ?? nil
    return gieft
}