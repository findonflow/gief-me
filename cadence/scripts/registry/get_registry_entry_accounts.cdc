import "../../contracts/FindRegistry.cdc"

pub fun main(owner: Address, publ: PublicPath, id: UInt64): [Address]? {
    if let entry = getAccount(owner).getCapability(publ).borrow<&FindRegistry.Registry{FindRegistry.RegistryPublic}>()?.get(id: id) {
        return entry?.getAccounts()
    } else {
        return nil
    }
}