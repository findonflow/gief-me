import "Giefts"

transaction {
    prepare(acct: AuthAccount) {
    if acct.borrow<&Giefts.GieftCollection>(from: Giefts.GieftsStoragePath) == nil {
        acct.save(<- Giefts.createGieftCollection(), to: Giefts.GieftsStoragePath)
    }

    acct.unlink(Giefts.GieftsPublicPath)
    acct.link<&Giefts.GieftCollection{Giefts.GieftCollectionPublic}>(Giefts.GieftsPublicPath, target: Giefts.GieftsStoragePath)

    acct.unlink(Giefts.GieftsPrivatePath)
    acct.link<&Giefts.GieftCollection{Giefts.GieftCollectionPublic, Giefts.GieftCollectionPrivate}>(Giefts.GieftsPrivatePath, target: Giefts.GieftsStoragePath)
    }
}