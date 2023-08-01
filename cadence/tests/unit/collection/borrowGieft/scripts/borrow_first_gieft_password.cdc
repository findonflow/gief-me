import "Giefts"

// Borrow a gieft from the gieft collection
// @param owner: the owner of the gieft
// @param gieftID: the ID of the gieft
// @return: the gieft reference

pub fun main(owner: Address): [UInt8]? {
    var gieft: &Giefts.Gieft{Giefts.GieftPublic}? = nil
    let ids = getAccount(owner).getCapability(Giefts.GieftsPublicPath).borrow<&Giefts.GieftCollection{Giefts.GieftCollectionPublic}>()?.getGieftIDs()!
    return getAccount(owner).getCapability(Giefts.GieftsPublicPath).borrow<&Giefts.GieftCollection{Giefts.GieftCollectionPublic}>()?.borrowGieft(ids[0])!?.password
}