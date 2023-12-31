import "NonFungibleToken"
import "MetadataViews"
import "FindRegistry"

//                      ___
//        __          /'___\
//    __ /\_\     __ /\ \__/         ___ ___      __
//  /'_ `\/\ \  /'__`\ \ ,__\      /' __` __`\  /'__`\
// /\ \L\ \ \ \/\  __/\ \ \_/      /\ \/\ \/\ \/\  __/
// \ \____ \ \_\ \____\\ \_\       \ \_\ \_\ \_\ \____\
//  \/___L\ \/_/\/____/ \/_/        \/_/\/_/\/_/\/____/
//    /\____/
//    \_/__/
// GiefMe - wrap NFT gifts in a box and send them to your friends.
// The gifts can be claimed by passing the correct password.
//
pub contract GiefMe {    
    /**//////////////////////////////////////////////////////////////
    //                           PATHS                            //
    /////////////////////////////////////////////////////////////**/

    pub let GiefMeStoragePath: StoragePath
    pub let GiefMePublicPath: PublicPath
    pub let GiefMePrivatePath: PrivatePath

    /**//////////////////////////////////////////////////////////////
    //                            EVENTS                           //
    /////////////////////////////////////////////////////////////**/

    pub event Packed(gieft: UInt64, nfts: [UInt64])
    pub event Added(gieft: UInt64, nft: UInt64, type: String, name: String, thumbnail: String)
    pub event Removed(gieft: UInt64, nft: UInt64, type: String, name: String, thumbnail: String)
    pub event Claimed(gieft: UInt64, nft: UInt64, type: String, name: String, thumbnail: String, gifter: Address?, giftee: Address?)

    /**//////////////////////////////////////////////////////////////
    //                         INTERFACES                          //
    /////////////////////////////////////////////////////////////**/

    /// Gieft

    pub resource interface GieftPublic {
        pub let password: [UInt8]
        pub fun borrowClaimableNFT(): &NonFungibleToken.NFT?
        pub fun claimNft(password: String, collection: &AnyResource{NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection})
        pub fun getNftIDs(): [UInt64]
    }

    /// GieftCollection

    pub resource interface GieftCollectionPublic {
        pub fun borrowGieft(_ gieft: UInt64): &Gieft{GieftPublic}?
        pub fun getGieftIDs(): [UInt64]
    }

    pub resource interface GieftCollectionPrivate {
        pub fun packGieft(name: String, password: [UInt8], nfts: @{UInt64: NonFungibleToken.NFT}, registryCapability: Capability<&FindRegistry.Registry{FindRegistry.RegistryPublic, FindRegistry.RegistryPrivate}>?)
        pub fun addNftToGieft(gieft: UInt64, nft: @NonFungibleToken.NFT)
        pub fun unpackGieft(gieft: UInt64): @{UInt64: NonFungibleToken.NFT} 
    }

    /**//////////////////////////////////////////////////////////////
    //                         RESOURCES                           //
    /////////////////////////////////////////////////////////////**/

    /// Gieft
    /// A collection of NFTs that can be claimed by passing the correct password

    pub resource Gieft: GieftPublic {
        ///  The name of the gieft
        pub let name: String
        /// A collection of NFTs
        /// nfts are stored as a map of uuids to NFTs
        access(contract) var nfts: @{UInt64: NonFungibleToken.NFT}
        /// Registry capability
        access(contract) let registryCapabilty: Capability<&FindRegistry.Registry{FindRegistry.RegistryPublic, FindRegistry.RegistryPrivate}>?
        /// The hashed password to claim an nft
        pub let password: [UInt8]
        /// A map of metadata fields 
        access (contract) var metadata: {String: AnyStruct}

        /// add an NFT to the gieft
        access(contract) fun addNft(nft: @NonFungibleToken.NFT) {
            pre {
                !self.nfts.keys.contains(nft.uuid) : "NFT uuid already added"
            }
            let display: MetadataViews.Display = nft.resolveView(Type<MetadataViews.Display>())! as! MetadataViews.Display
            emit Added(gieft: self.uuid, nft: nft.uuid, type: nft.getType().identifier, name: display.name, thumbnail: display.thumbnail.uri())
            let oldNft <- self.nfts[nft.uuid] <-nft
            destroy oldNft
        }

        /// borrwClaimableNFT
        /// get a reference to the first NFT that can be claimed
        /// @returns the first NFT that can be claimed
        pub fun borrowClaimableNFT(): &NonFungibleToken.NFT? {
            if self.nfts.length > 0 {
                return &self.nfts[self.nfts.keys[0]] as &NonFungibleToken.NFT?
            } else {
                return nil
            }
        }

        /// claim an NFT from the gieft
        /// @params password: the password to claim the NFT
        pub fun claimNft(password: String, collection: &AnyResource{NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}) {
            pre {
                self.password ==  HashAlgorithm.KECCAK_256.hash(password.utf8) : "Incorrect password"
                self.nfts.length > 0 : "No NFTs to claim"
            }
           
            // check if the registry capability is set
            if self.registryCapabilty != nil {
                // get the registry capability
                let registry = self.registryCapabilty!.borrow() ?? panic("Could not borrow registry capability")

                // get collection owner
                let owner = collection.owner!.address

                // clear expired registry entries
                registry.clearExpired(ids: [self.uuid])

                // check if the NFT has already been claimed
                if (registry.contains(id: self.uuid, account: owner)) {
                    panic ("Gieft already claimed")
                } else {
                    // claim the NFT
                    self.claim(collection: collection)

                    // add the owner to the registry
                    registry.add(id: self.uuid, account: owner)
                }
            } else {
                // claim the NFT
                self.claim(collection: collection)
            }
        }

        access(self) fun claim(collection: &AnyResource{NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection}) {
            // remove the NFT from the gieft
            let nft <- self.nfts.remove(key: self.nfts.keys[0])!

            // get the display metadata
            let display: MetadataViews.Display = nft.resolveView(Type<MetadataViews.Display>())! as! MetadataViews.Display

            // emit the claimed event
            emit Claimed(gieft: self.uuid, nft: nft.uuid, type: nft.getType().identifier, name: display.name, thumbnail: display.thumbnail.uri(), gifter: self.owner?.address, giftee: collection.owner?.address)

            // deposit the NFT in the collection
            collection.deposit(token: <- nft)
        }

        /// unpack, a function to unpack an NFT from the gieft, this function is only callable by the owner
        /// @params nft: the uuid of the NFT to claim
        access(contract) fun unpack(nft: UInt64): @NonFungibleToken.NFT {
            pre {
                self.nfts.keys.contains(nft) : "NFT does not exist"
            }
            let nft <- self.nfts.remove(key: nft)!
            let display: MetadataViews.Display = nft.resolveView(Type<MetadataViews.Display>())! as! MetadataViews.Display
            emit Removed(gieft: self.uuid, nft: nft.uuid, type: nft.getType().identifier, name: display.name, thumbnail: display.thumbnail.uri())
            return <-nft
        }

        /// get all NFT ids
        pub fun getNftIDs(): [UInt64] {
            return self.nfts.keys
        }

        init (name: String, password: [UInt8], nfts: @{UInt64: NonFungibleToken.NFT}, registryCapability: Capability<&FindRegistry.Registry{FindRegistry.RegistryPublic, FindRegistry.RegistryPrivate}>?) {
            self.name = name
            self.nfts <- nfts
            self.password = password
            self.registryCapabilty = registryCapability
            self.metadata = {}
            emit Packed(gieft: self.uuid, nfts: self.nfts.keys)
        }

        destroy () {
            pre {
                self.nfts.length == 0 : "All NFTs must be claimed before destroying the gieft"
            }
            destroy self.nfts
        }
    }

    /// GieftCollection
    /// A collection of GiefMe

    pub resource GieftCollection: GieftCollectionPublic, GieftCollectionPrivate  {
        /// a collection of GiefMe
        pub var GiefMe: @{UInt64: Gieft}

        /// create a new gieft
        /// @params password: the hashed password to claim an NFT from the Gieft
        /// @params nfts: the NFTs to add to the gieft
        pub fun packGieft(name: String, password: [UInt8], nfts: @{UInt64: NonFungibleToken.NFT}, registryCapability: Capability<&FindRegistry.Registry{FindRegistry.RegistryPublic, FindRegistry.RegistryPrivate}>?) {
            let gieft <- create Gieft(name: name, password: password, nfts: <- nfts, registryCapability: registryCapability)
            let oldGieft <- self.GiefMe[gieft.uuid] <- gieft
            destroy oldGieft
        }

        /// add an NFT to a gieft
        /// @params gieft: the uuid of the gieft to add the NFT to
        /// @params nft: the NFT to add to the gieft
        pub fun addNftToGieft(gieft: UInt64, nft: @NonFungibleToken.NFT) {
            pre {
                self.GiefMe.keys.contains(gieft) : "Gieft does not exist"
            }
            self.borrowGieft(gieft)!.addNft(nft: <-nft)
        }

        /// unpack a gieft
        /// @params gieft: the uuid of the gieft to unpack
        pub fun unpackGieft(gieft: UInt64): @{UInt64: NonFungibleToken.NFT} {
            pre {
                self.GiefMe.keys.contains(gieft) : "Gieft does not exist"
            }
            var nfts: @{UInt64: NonFungibleToken.NFT} <- {}

            let gieft = self.borrowGieft(gieft)!
            let nftIDs = gieft.getNftIDs()
            for nftID in nftIDs {
                let nft <- gieft.unpack(nft: nftID)
                let oldNft <- nfts[nftID] <- nft
                destroy oldNft
            }
            return <-nfts
        }

        /// borrow a gieft reference
        /// @params gieft: the uuid of the gieft to borrow
        pub fun borrowGieft(_ gieft: UInt64): &Gieft? {
            return &self.GiefMe[gieft] as &Gieft?
        }

        /// get all gieft ids
        pub fun getGieftIDs(): [UInt64] {
            return self.GiefMe.keys
        }

        init () {
            self.GiefMe <- {}
        }

        destroy () {
            destroy self.GiefMe
        }
    }

    /**//////////////////////////////////////////////////////////////
    //                         FUNCTIONS                           //
    /////////////////////////////////////////////////////////////**/

    /// create a new gieft collection resource
    pub fun createGieftCollection (): @GieftCollection {
        return <-create GieftCollection()
    }

    init () {
        /// paths
        self.GiefMeStoragePath = /storage/GiefMe
        self.GiefMePublicPath = /public/GiefMe
        self.GiefMePrivatePath = /private/GiefMe
    }
}