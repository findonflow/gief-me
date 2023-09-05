import "NonFungibleToken"
import "MetadataViews"

// GieftRegistry - A registry for tracking gieftIDs and the accounts that have claimed them
// This is used to prevent a gieftID from being claimed more than once
//
pub contract GieftRegistry {
    
    /**//////////////////////////////////////////////////////////////
    //                           STRUCTS                           //
    /////////////////////////////////////////////////////////////**/

    /// RegistryEntry 
    /// A struct for tracking the accounts that have claimed a gieftID
    /// and the block height that the gieftID was added to the registry
    pub struct RegistryEntry {
        pub let blockHeight: UInt64
        access (contract) var accounts: [Address]
        
        pub fun init(blockHeight: UInt64) {
            self.blockHeight = blockHeight
            self.accounts = []
        }

        access (contract) addAccount(account: Address) {
            self.accounts.append(account)
        }

        access (contract) removeAccount(account: Address) {
            self.accounts.remove(account)
        }

        pub fun getAccounts(): [Address] {
            return self.accounts
        }
    }

    /**//////////////////////////////////////////////////////////////
    //                            VARS                            //
    /////////////////////////////////////////////////////////////**/

    /// The registry is a dictionary of giftID to RegistryEntry
    access(contract) var registry: {UInt64: RegistryEntry}

    /// The registryTTL is the number of blocks that a gieft will be in the registry
    pub var registryTTL: UInt64
    
    /**//////////////////////////////////////////////////////////////
    //                            PATHS                            //
    /////////////////////////////////////////////////////////////**/

    pub let OperatorStoragePath: StoragePath
    pub let OperatorPrivatePath: PrivatePath

    /**//////////////////////////////////////////////////////////////
    //                            EVENTS                           //
    /////////////////////////////////////////////////////////////**/

    pub event AddedToRegistry(address: Address, gieftID: UInt64, blockHeight: UInt64)
    pub event RemovedFromRegistry(address: Address, gieftID: UInt64, blockHeight: UInt64)
    pub event UpdatedRegistryTTL(ttl: UInt64)

    /**//////////////////////////////////////////////////////////////
    //                         INTERFACES                          //
    /////////////////////////////////////////////////////////////**/

    pub resource interface IGieftRegistryOperator {
        pub fun addToRegistry(gieftID: UInt64, account: Address)
        pub fun updateRegistryTTL(ttl: UInt64)
        pub fun createOperator(): @Operator
    }

    /**//////////////////////////////////////////////////////////////
    //                         RESOURCES                           //
    /////////////////////////////////////////////////////////////**/

    /// Operator
    /// The operator resource is used to add gieftIDs to the registry
    /// and update the registryTTL
    pub resource Operator: IGieftRegistryOperator {
        
        /// addToRegistry
        /// Add a gieftID to the registry
        /// - Parameter gieftID: The gieftID to add to the registry
        /// - Parameter account: The account that claimed the gieftID
        pub fun addToRegistry(gieftID: UInt64, account: Address) {
            // get the current block height
            let blockHeight: UInt64 = getCurrentBlock().height

            // check if registy exists for this gieftID
            if GieftsRegistry.registry[gieftID] == nil {
                // create a new registry entry
                let registryEntry = RegistryEntry(blockHeight: blockHeight)
                registryEntry.addAccount(account: account)
                GieftsRegistry.registry[gieftID] = registryEntry
            } else {
                // get the registry entry
                let registryEntry = GieftsRegistry.registry[gieftID]

                // check if the block height is expired
                if registryEntry.blockHeight + GieftsRegistry.registryTTL < blockHeight {
                    registryEntry.addAccount(account: account)
                                    
                    // emit event
                    emit AddedToRegistry(address: account, gieftID: gieftID, blockHeight: blockHeight)
                } else {
                   return
                }
            }
        }

        /// updateRegistryTTL
        /// Update the registryTTL
        /// - Parameter ttl: The new registryTTL
        pub fun updateRegistryTTL(ttl: UInt64) {
            GieftsRegistry.registryTTL = ttl
            emit UpdatedRegistryTTL(ttl: ttl)
        }

        /// createOperator
        /// Create and return new operator resource
        pub fun createOperator(): @Operator {
            return <- create Operator()
        }
    }

    /**//////////////////////////////////////////////////////////////
    //                         FUNCTIONS                           //
    /////////////////////////////////////////////////////////////**/

    /// removeExpiredGiefts
    /// Remove gieftIDs from the registry that have expired
    /// - Parameter gieftIDs: The gieftIDs to remove from the registry
    pub fun removeExpiredGiefts(gieftIDs: [UInt64]) {
        // get the current block height
        let blockHeight =  getCurrentBlock()

        // loop through gieftIDs
        for gieftID in gieftIDs {
            // check if registy exists for this gieftID
            if GieftsRegistry.registry[gieftID] != nil {
                // get the registry entry
                let registryEntry = GieftsRegistry.registry[gieftID]

                // check if the block height is expired
                if registryEntry.blockHeight + GieftsRegistry.registryTTL < blockHeight {
                    // loop through accounts
                    for account in registryEntry.accounts {
                        // emit event
                        emit RemovedFromRegistry(address: account, gieftID: gieftID, blockHeight: registryEntry.blockHeight)
                    }

                    // remove the registry entry
                    GieftsRegistry.registry.remove(key: gieftID)
                }
            }
        }
    }

    /// getAccountsForGieftID
    /// Get the accounts that have claimed a gieftID
    /// - Parameter gieftID: The gieftID to get the accounts for
    pub fun getAccountsForGieftID(gieftID: UInt64): [Address] {
        // check if registy exists for this gieftID
        if GieftsRegistry.registry[gieftID] != nil {
            // get the registry entry
            let registryEntry = GieftsRegistry.registry[gieftID]

            // return the accounts
            return registryEntry.getAccounts()
        } else {
            return []
        }
    }

    /// getRegistryEntryForGieftID
    /// Get the registry entry for a gieftID
    /// - Parameter gieftID: The gieftID to get the registry entry for
    pub fun getRegistryEntryForGieftId(gieftID: UInt64): RegistryEntry? {
        // check if registy exists for this gieftID
        if GieftsRegistry.registry[gieftID] != nil {
            // get the registry entry
            let registryEntry = GieftsRegistry.registry[gieftID]

            // return the registry entry
            return registryEntry
        } else {
            return nil
        }
    }

    /// isAccountInGieftIDRegistry
    /// Check if an account is in the registry for a gieftID
    /// - Parameter gieftID: The gieftID to check the registry for
    /// - Parameter account: The account to check the registry for
    pub fun isAccountInGieftIDRegistry(gieftID: UInt64, account: Address): Bool {
        // check if registy exists for this gieftID
        if GieftsRegistry.registry[gieftID] != nil {
            // get the registry entry
            let registryEntry = GieftsRegistry.registry[gieftID]

            // return if the account is in the registry
            return registryEntry.accounts.contains(account)
        } else {
            return false
        }
    }

    init () {
        // vars
        self.registry = {}
        self.registryTTL = 100

        // paths
        self.OperatorStoragePath=/storage/GieftsRegistryOperator
        self.OperatorPrivatePath=/private/GieftsRegistryPrivate

        // operator resource
        self.account.save(<- create Operator(), to: self.OperatorStoragePath)
        self.account.link<&Operator>(self.OperatorPrivatePath, target: self.OperatorStoragePath)
    }
}