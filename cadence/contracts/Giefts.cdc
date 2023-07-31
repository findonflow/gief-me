import "NonFungibleToken"

//                      _       __ _
//                __ _(_) ___ / _| |_ ___
//              / _` | |/ _ \ |_| __/ __|
//             | (_| | |  __/  _| |_\__ \
//             \__, |_|\___|_|  \__|___/
//             |___/
//
// Giefts - wrap NFT gifts in a box and send them to your friends.
// The gifts can be claimed by passing the correct password.
//
pub contract Giefts {
    
    /**//////////////////////////////////////////////////////////////
    //                            PATHS                            //
    /////////////////////////////////////////////////////////////**/

    pub let GieftsStoragePath: StoragePath
    pub let GieftsPublicPath: PublicPath
    pub let GieftsPrivatePath: PrivatePath

    /**//////////////////////////////////////////////////////////////
    //                            EVENTS                           //
    /////////////////////////////////////////////////////////////**/

    pub event Packed(gieft: UInt64, nfts: [UInt64])
    pub event Added(gieft: UInt64, nft: UInt64)
    pub event Claimed(gieft: UInt64, nft: UInt64)
    pub event Unpacked(gieft: UInt64, nft: UInt64)

    /**//////////////////////////////////////////////////////////////
    //                         INTERFACES                          //
    /////////////////////////////////////////////////////////////**/

    // Gieft

    pub resource interface GieftPublic {
        pub let password: [UInt8]
        pub fun claimNft(password: String): @NonFungibleToken.NFT
        pub fun getNftIDs(): [UInt64]
    }

    pub resource interface GieftPrivate {
        access(contract) fun addNft(nft: @NonFungibleToken.NFT)
        access(contract) fun unpack(nft: UInt64): @NonFungibleToken.NFT
    }

    // GieftCollection

    pub resource interface GieftCollectionPublic {
        pub fun borrowGieft(_ gieft: UInt64): &Gieft{GieftPublic}?
        pub fun getGieftIDs(): [UInt64]
    }

    pub resource interface GieftCollectionPrivate {
        pub fun packGieft(password: [UInt8], nfts: @{UInt64: NonFungibleToken.NFT})
        pub fun addNftToGieft(gieft: UInt64, nft: @NonFungibleToken.NFT)
        pub fun unpackGieft(gieft: UInt64): @{UInt64: NonFungibleToken.NFT} 
    }

    /**//////////////////////////////////////////////////////////////
    //                         RESOURCES                           //
    /////////////////////////////////////////////////////////////**/

    // Gieft
    // A collection of NFTs that can be claimed by passing the correct password

    pub resource Gieft: GieftPublic, GieftPrivate {
        // A collection of NFTs
        // nfts are stored as a map of uuids to NFTs
        access(contract) var nfts: @{UInt64: NonFungibleToken.NFT}

        // The hashed password to claim an nft
        pub let password: [UInt8]

        // add an NFT to the gieft
        access(contract) fun addNft(nft: @NonFungibleToken.NFT) {
            pre {
                !self.nfts.keys.contains(nft.uuid) : "NFT uuid already added"
            }
            emit Added(gieft: self.uuid, nft: nft.uuid)
            let oldNft <- self.nfts[nft.uuid] <-nft
            destroy oldNft
        }

        // claim an NFT from the gieft
        // @params password: the password to claim the NFT
        pub fun claimNft(password: String): @NonFungibleToken.NFT {
            pre {
                self.password ==  HashAlgorithm.KECCAK_256.hash(password.utf8) : "Incorrect password"
                self.nfts.length > 0 : "No NFTs to claim"
            }
            let nft <- self.nfts.remove(key: self.nfts.keys[0])!
            emit Claimed(gieft: self.uuid, nft: nft.uuid)
            return <-nft
        }

        // unpack, a function to unpack an NFT from the gieft, this function is only callable by the owner
        // @params nft: the uuid of the NFT to claim
        access(contract) fun unpack(nft: UInt64): @NonFungibleToken.NFT {
            pre {
                self.nfts.keys.contains(nft) : "NFT does not exist"
            }
            let nft <- self.nfts.remove(key: nft)!
            emit Unpacked(gieft: self.uuid, nft: nft.uuid)
            return <-nft
        }

        // get all NFT ids
        pub fun getNftIDs(): [UInt64] {
            return self.nfts.keys
        }

        init (password: [UInt8], nfts: @{UInt64: NonFungibleToken.NFT}) {
            self.nfts <- nfts
            self.password = password
            emit Packed(gieft: self.uuid, nfts: self.nfts.keys)
        }

        destroy () {
            pre {
                self.nfts.length == 0 : "All NFTs must be claimed before destroying the gieft"
            }
            destroy self.nfts
        }
    }

    // GieftCollection
    // A collection of giefts

    pub resource GieftCollection: GieftCollectionPublic, GieftCollectionPrivate  {
        // a collection of giefts
        pub var giefts: @{UInt64: Gieft}

        // create a new gieft
        // @params password: the hashed password to claim an NFT from the Gieft
        // @params nfts: the NFTs to add to the gieft
        pub fun packGieft(password: [UInt8], nfts: @{UInt64: NonFungibleToken.NFT}) {
            let gieft <- create Gieft(password: password, nfts: <- nfts)
            let oldGieft <- self.giefts[gieft.uuid] <- gieft
            destroy oldGieft
        }

        // add an NFT to a gieft
        // @params gieft: the uuid of the gieft to add the NFT to
        // @params nft: the NFT to add to the gieft
        pub fun addNftToGieft(gieft: UInt64, nft: @NonFungibleToken.NFT) {
            pre {
                self.giefts.keys.contains(gieft) : "Gieft does not exist"
            }
            self.borrowGieftPrivate(gieft)!.addNft(nft: <-nft)
        }

        // unpack a gieft
        // @params gieft: the uuid of the gieft to unpack
        pub fun unpackGieft(gieft: UInt64): @{UInt64: NonFungibleToken.NFT} {
            pre {
                self.giefts.keys.contains(gieft) : "Gieft does not exist"
            }
            var nfts: @{UInt64: NonFungibleToken.NFT} <- {}

            let gieft = self.borrowGieftPrivate(gieft)!
            let nftIDs = gieft.getNftIDs()
            for nftID in nftIDs {
                let nft <- gieft.unpack(nft: nftID)
                let oldNft <- nfts[nftID] <- nft
                destroy oldNft
            }
            return <-nfts
        }

        // borrow a gieft reference
        // @params gieft: the uuid of the gieft to borrow
        pub fun borrowGieft(_ gieft: UInt64): &Gieft{GieftPublic}? {
            return &self.giefts[gieft] as &Gieft?
        }

        access(contract) fun borrowGieftPrivate(_ gieft: UInt64): &Gieft{GieftPrivate, GieftPublic}? {
            return &self.giefts[gieft] as &Gieft?
        }

        // get all gieft ids
        pub fun getGieftIDs(): [UInt64] {
            return self.giefts.keys
        }

        init () {
            self.giefts <- {}
        }

        destroy () {
            destroy self.giefts
        }
    }

    /**//////////////////////////////////////////////////////////////
    //                         FUNCTIONS                           //
    /////////////////////////////////////////////////////////////**/

    // create a new gieft collection resource
    pub fun createGieftCollection (): @GieftCollection {
        return <-create GieftCollection()
    }

    init () {
        // paths
        self.GieftsStoragePath = /storage/Giefts
        self.GieftsPublicPath = /public/Giefts
        self.GieftsPrivatePath = /private/Giefts
    }
}