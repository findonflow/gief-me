import "../../contracts/FindRegistry.cdc"

pub fun main(owner: Address, publ: PublicPath, ids: [UInt64]) {
    getAccount(owner).getCapability(publ).borrow<&FindRegistry.Registry{FindRegistry.RegistryPublic}>()?.clearExpired(ids: ids)
}