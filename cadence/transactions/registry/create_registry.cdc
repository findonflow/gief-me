import "../../contracts/FindRegistry.cdc"

transaction (stor: StoragePath, priv: PrivatePath, publ: PublicPath, ttl: UInt64) {
    prepare(acct: AuthAccount) {
        if acct.borrow<&FindRegistry.Registry>(from: stor) == nil {
            acct.save(<- FindRegistry.createRegistry(ttl: ttl), to: stor)
            acct.link<&FindRegistry.Registry{FindRegistry.RegistryPublic}>(publ, target: stor)
            acct.link<&FindRegistry.Registry{FindRegistry.RegistryPublic, FindRegistry.RegistryPrivate}>(priv, target: stor)
        }
    }
}