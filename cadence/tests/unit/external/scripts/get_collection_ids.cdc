import "NonFungibleToken"
import "ExampleNFT"

pub fun main(owner: Address): [UInt64] {
    return getAccount(owner).getCapability(ExampleNFT.CollectionPublicPath).borrow<&{NonFungibleToken.CollectionPublic}>()!.getIDs()
}