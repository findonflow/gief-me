import "../../modules/flow-utils/cadence/contracts/NonFungibleToken.cdc";

//                      _       __ _
//                __ _(_) ___ / _| |_ ___
//               / _` | |/ _ \ |_| __/ __|
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
        pub fun claimNft(_password: String): @NonFungibleToken.NFT
    }

    pub resource interface GieftPrivate {
        access(contract) fun addNft(_nft: @NonFungibleToken.NFT)
        access(contract) fun unpack(_nft: UInt64): @NonFungibleToken.NFT
    }

    // GieftCollection

    pub resource interface GieftCollectionPublic {
        pub fun borrowGieft(_ _gieft: UInt64): &Gieft?
        pub fun getGieftIDs(): [UInt64]
    }

    pub resource interface GieftCollectionPrivate {
        pub fun packGieft(_password: [UInt8], _nfts: @{UInt64: NonFungibleToken.NFT})
        pub fun addNftToGieft(_gieft: UInt64, _nft: @NonFungibleToken.NFT)
        pub fun unpackGiefts(_giefts: [UInt64]): @[NonFungibleToken.NFT]
    }

    /**//////////////////////////////////////////////////////////////
    //                         RESOURCES                           //
    /////////////////////////////////////////////////////////////**/

    // Gieft
    // A collection of NFTs that can be claimed by passing the correct password

    pub resource Gieft: GieftPublic, GieftPrivate {
        // A collection of NFTs
        access(contract) var nfts: @{UInt64: NonFungibleToken.NFT}

        // The hashed password to claim an nft
        pub var password: [UInt8]
        
        // a map of addresses that have claimed the gift
        pub var claimed: {Address: Bool}

        // add an NFT to the gieft
        access(contract) fun addNft(_nft: @NonFungibleToken.NFT) {
            pre {
                !self.nfts.keys.contains(_nft.uuid) : "NFT uuid already added"
            }
            emit Added(gieft: self.uuid, nft: _nft.uuid)
            let oldNft <- self.nfts[_nft.uuid] <-_nft
            destroy oldNft
        }

        // claim an NFT from the gieft
        // @params _password: the password to claim the NFT
        pub fun claimNft(_password: String): @NonFungibleToken.NFT {
            pre {
                self.password ==  HashAlgorithm.KECCAK_256.hash(_password.utf8) : "Incorrect password"
                self.nfts.length > 0 : "No NFTs to claim"
            }
            let nft <- self.nfts.remove(key: self.nfts.keys[0])!
            emit Claimed(gieft: self.uuid, nft: nft.uuid)
            return <-nft
        }

        // unpack, a function to unpack an NFT from the gieft, this function is only callable by the owner
        // @params _nft: the uuid of the NFT to claim
        access(contract) fun unpack(_nft: UInt64): @NonFungibleToken.NFT {
            pre {
                self.nfts.keys.contains(_nft) : "NFT does not exist"
            }
            let nft <- self.nfts.remove(key: _nft)!
            emit Unpacked(gieft: self.uuid, nft: nft.uuid)
            return <-nft
        }

        init (password: [UInt8], nfts: @{UInt64: NonFungibleToken.NFT}) {
            self.nfts <- nfts
            self.password = password
            self.claimed = {}
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
        // @params _password: the hashed password to claim an NFT from the Gieft
        // @params _nfts: the NFTs to add to the gieft
        pub fun packGieft(_password: [UInt8], _nfts: @{UInt64: NonFungibleToken.NFT}) {
            let gieft <- create Gieft(password: _password, nfts: <- _nfts)
            let oldGieft <- self.giefts[gieft.uuid] <- gieft
            destroy oldGieft
        }

        // add an NFT to a gieft
        // @params _gieft: the uuid of the gieft to add the NFT to
        // @params _nft: the NFT to add to the gieft
        pub fun addNftToGieft(_gieft: UInt64, _nft: @NonFungibleToken.NFT) {
            pre {
                self.giefts.keys.contains(_gieft) : "Gieft does not exist"
            }
            self.borrowGieft(_gieft)!.addNft(_nft: <-_nft)
        }

        // unpack a gieft
        // @params _gieft: the uuid(s) of the gieft(s) to unpack
        pub fun unpackGiefts(_giefts: [UInt64]): @[NonFungibleToken.NFT] {
            var nfts: @[NonFungibleToken.NFT] <- []
            for gieft in _giefts {
                nfts.append( <- self.borrowGieft(gieft)!.unpack(_nft: gieft))
            }
            return <-nfts
        }

        // borrow a gieft reference
        // @params _gieft: the uuid of the gieft to borrow
        pub fun borrowGieft(_ _gieft: UInt64): &Gieft? {
            return &self.giefts[_gieft] as &Gieft?
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

    // get the gieft collection resource from an address
    // @params _from: the address to get the gieft collection from
    // @params _gieft: the gieft uuid to fetch
    // @returns: the gieft resource
    pub fun fetch(_ from: Address, _gieft: UInt64): &Gieft? {
        let capability = getAccount(from).getCapability<&GieftCollection>(/public/GieftsCollection)
        if capability.check() {
            return capability.borrow()!.borrowGieft(_gieft)
        } else {
            return nil
        }
    }

    init () {
        // paths
        self.GieftsStoragePath = /storage/Giefts
        self.GieftsPublicPath = /public/Giefts
        self.GieftsPrivatePath = /private/Giefts
    }
}