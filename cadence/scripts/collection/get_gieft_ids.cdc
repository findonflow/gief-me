import "GiefMe"

// This script returns the IDs of all the giefts owned by the given address
// If the address doesn't own any giefts, it returns nil

pub fun main(owner: Address): [UInt64]? {
    var ids =nil as [UInt64]?
    ids = getAccount(owner).getCapability(GiefMe.GiefMePublicPath).borrow<&GiefMe.GieftCollection{GiefMe.GieftCollectionPublic}>()?.getGieftIDs()
    return ids
}