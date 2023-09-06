import "../../contracts/FindRegistry.cdc"

transaction (stor: StoragePath, ttl: UInt64) {
    let registry: &FindRegistry.Registry{FindRegistry.RegistryPrivate}

    prepare(acct: AuthAccount) {
        self.registry = acct.borrow<&FindRegistry.Registry{FindRegistry.RegistryPrivate}>(from: stor) 
            ?? panic("Could not borrow private registry capability")
    } 
    
    execute {
        self.registry.updateTTL(ttl: ttl)
    }
}