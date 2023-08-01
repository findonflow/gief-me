import "Giefts"

// Borrow a gieft from the gieft collection
// @param owner: the owner of the gieft
// @param gieftID: the ID of the gieft
// @return: the gieft reference

pub fun main(owner: Address, gieftID: UInt64): &Giefts.Gieft{Giefts.GieftPublic}? {
    var gieft: &Giefts.Gieft{Giefts.GieftPublic}? = nil
    gieft = getAccount(owner).getCapability(Giefts.GieftsPublicPath).borrow<&Giefts.GieftCollection{Giefts.GieftCollectionPublic}>()?.borrowGieft(gieftID) ?? nil
    return gieft
}