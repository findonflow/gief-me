import "Giefts"
import "NonFungibleToken"
import "ExampleNFT"

// This transaction attempts to pack a gieft by using another accounts GieftCollection Public Capability
// it should fail because the packGieft function is only available to the GieftCollection Private Capability which is
// only available to the owner of the GieftCollection

transaction(owner: Address) {

    let capabilityPublic: Capability<&Giefts.GieftCollection{Giefts.GieftCollectionPublic}>
    let nfts: @{UInt64: NonFungibleToken.NFT}

    prepare(acct: AuthAccount) {
        self.capabilityPublic = getAccount(owner).getCapability<&Giefts.GieftCollection{Giefts.GieftCollectionPublic}>(Giefts.GieftsPublicPath)
        self.nfts <- {}
        let id = acct.borrow<&ExampleNFT.Collection>(from: ExampleNFT.CollectionStoragePath)!.getIDs()[0]
        let nft <- acct.borrow<&ExampleNFT.Collection>(from: ExampleNFT.CollectionStoragePath)!.withdraw(withdrawID: id)
        let oldNft <- self.nfts[nft.uuid] <- nft
        destroy oldNft
    }

    execute {
        let password: [UInt8] = HashAlgorithm.KECCAK_256.hash("abracadabra".utf8)
        self.capabilityPublic.borrow()!.packGieft(name: "Test", password: password, nfts: <- self.nfts)
    }
}