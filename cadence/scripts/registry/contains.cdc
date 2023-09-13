import "../../contracts/FindRegistry.cdc"

pub fun main(owner: Address, publ: PublicPath, id: UInt64, account: Address): Bool? {
   return getAccount(owner).getCapability(publ).borrow<&FindRegistry.Registry{FindRegistry.RegistryPublic}>()?.contains(id: id, account: account)
}