import "NonFungibleToken"
import "MetadataViews"

// FindRegistry 
// - A contract that allows for the creation of registries
// - Registries are used to store a list of accounts for a UUID and TTL
pub contract FindRegistry {
    
    /**//////////////////////////////////////////////////////////////
    //                           STRUCTS                           //
    /////////////////////////////////////////////////////////////**/

    /// RegistryEntry 
    ///
    /// 
    pub struct RegistryEntry {
        pub let blockHeight: UInt64
        access (contract) var accounts: {Address: Bool}
        
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

        pub fun containsAccount(account: Address): Bool {
            return self.accounts[account] != nil
        }
    }

    /**//////////////////////////////////////////////////////////////
    //                            EVENTS                           //
    /////////////////////////////////////////////////////////////**/

    pub event Added(registry: UInt64, address: Address, id: UInt64, blockHeight: UInt64)
    pub event Removed(registry: UInt64, address: Address, id: UInt64, blockHeight: UInt64)
    pub event Cleared(registry: UInt64, id: UInt64)
    pub event UpdatedTTL(registry: UInt64, ttl: UInt64)
    pub event Deleted(registry: UInt64, owner: Address?)

    /**//////////////////////////////////////////////////////////////
    //                         INTERFACES                          //
    /////////////////////////////////////////////////////////////**/

    pub resource interface RegistryPublic {
        pub fun get(id: UInt64): RegistryEntry?
        pub fun contains(id: UInt64, account: Address): Bool
        pub fun clearExpired(ids: [UInt64])
    }

    pub resource interface RegistryPrivate {
        pub fun add(id: UInt64, account: Address)
        pub fun remove(id: UInt64, account: Address)
        pub fun updateTTL(ttl: UInt64)
    }

    /**//////////////////////////////////////////////////////////////
    //                         RESOURCES                           //
    /////////////////////////////////////////////////////////////**/

    /// Registry
    ///
    ///
    pub resource Entry: RegistryPublic, RegistryPrivate {
        /// A dictionary of UUIDs to registry entries
        pub var registry: {UInt64: RegistryEntry}

        /// The registry's TTL
        pub var registryTTL: UInt64

        /// add
        /// Add an account to the registry for a UUID
        /// - Parameter id: The UUID to add to the registry
        /// - Parameter account: The account to add to the registry
        pub fun add(id: UInt64, account: Address) {
            let blockHeight: UInt64 = getCurrentBlock().height

            // check if registy exists for this UUID
            if self.registry[id] == nil {
                // create a new registry entry
                let registryEntry = RegistryEntry(blockHeight: blockHeight)
                registryEntry.addAccount(account: account)
                self.registry[id] = registryEntry
            } else {
                // get the registry entry
                let registryEntry = self.registry[id]

                // check if the block height is expired
                if registryEntry.blockHeight + self.registryTTL < blockHeight {
                    registryEntry.addAccount(account: account)
                    // emit event
                    emit Added(registry: self.uuid, address: account, gieftID: id, blockHeight: blockHeight)
                } else {
                   return
                }
            }
        }

        /// remove
        /// Remove an account from the registry for a UUID
        /// - Parameter id: The UUID to remove from the registry
        /// - Parameter account: The account to remove from the registry
        pub fun remove(id: UInt64, account: Address) {
            // check if registy exists for this UUID
            if self.registry[id] != nil {
                // get the registry entry
                let registryEntry = self.registry[id]

                // remove the account from the registry
                registryEntry.removeAccount(account: account)

                // emit event
                emit RemovedFromRegistry(registry: self.uuid, address: account, id: id, blockHeight: registryEntry.blockHeight)
            }
        }

        /// updateTTL
        /// Update the registry's TTL
        /// - Parameter ttl: The new TTL
        pub fun updateTTL(ttl: UInt64) {
            self.registryTTL = ttl
            emit UpdatedTTL(registry: self.uuid, ttl: ttl)
        }

        /// get
        /// Get the registry entry for a UUID
        /// - Parameter id: The UUID to get the registry entry for
        pub fun get(id: UInt64): RegistryEntry? {
            return self.registry[id]
        }

        /// contains
        /// Check if an account is in the registry for a UUID
        /// - Parameter id: The UUID to check the registry for
        /// - Parameter account: The account to check the registry for
        pub fun contains(id: UInt64, account: Address): Bool {
            if self.registry[id] != nil {
                let registryEntry = self.registry[id]
                return registryEntry.containsAccount(account: account)
            } else {
                return false
            }
        }

        /// clearExpired
        /// Clear expired registry entries
        /// - Parameter ids: The UUIDs to clear
        pub fun clearExpired(ids: [UInt64]) {
            let blockHeight: UInt64 = getCurrentBlock().height

            for id in ids {
                if self.registry[id] != nil {
                    let registryEntry = self.registry[id]
                    if registryEntry.blockHeight + self.registryTTL < blockHeight {
                        self.registry.remove(id)
                    }
                    emit Cleared(registry: self.uuid, id: id)
                }
            }
        }

        init (ttl: UInt64) {
            self.registry = {}
            self.registryTTL = ttl
        }

        destroy() {
            emit Deleted(registry: self.uuid, owner: self.owner?.address)
        }
    }

    /**//////////////////////////////////////////////////////////////
    //                         FUNCTIONS                           //
    /////////////////////////////////////////////////////////////**/

    /// createRegistry
    /// Create and return new registry resource
    /// - Parameter ttl: The registry's TTL
    pub fun createRegistry(ttl: UInt64): @Registry {
        return <- create Registry(ttl: ttl)
    }

    init () {
        ///
    }   
}