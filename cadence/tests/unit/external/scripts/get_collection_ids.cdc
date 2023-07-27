import "ExampleNFT"

pub fun main(owner: Address): [UInt64] {
    return getAccount(owner).getCapability(ExampleNFT.CollectionPublicPath).borrow<&{ExampleNFT.ExampleNFTCollectionPublic}>()!.getIDs()
}