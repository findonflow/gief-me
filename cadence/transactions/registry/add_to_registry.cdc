import "FindRegistry"

transaction (stor: StoragePath, id: UInt64, account: Address) {
    let registry: &FindRegistry.Registry{FindRegistry.RegistryPrivate}

    prepare(acct: AuthAccount) {
        self.registry = acct.borrow<&FindRegistry.Registry{FindRegistry.RegistryPrivate}>(from: stor) 
            ?? panic("Could not borrow private registry capability")
    } 

    execute {
        self.registry.add(id: id, account: account)
    }
}