import "GiefMe"

// This transaction initializes the GieftCollection for the signer
// and sets up the public/private capability links

transaction {
    prepare(acct: AuthAccount) {
        if acct.borrow<&GiefMe.GieftCollection>(from: GiefMe.GiefMeStoragePath) == nil {
            acct.save(<- GiefMe.createGieftCollection(), to: GiefMe.GiefMeStoragePath)
        }

        acct.unlink(GiefMe.GiefMePublicPath)
        acct.link<&GiefMe.GieftCollection{GiefMe.GieftCollectionPublic}>(GiefMe.GiefMePublicPath, target: GiefMe.GiefMeStoragePath)

        acct.unlink(GiefMe.GiefMePrivatePath)
        acct.link<&GiefMe.GieftCollection{GiefMe.GieftCollectionPublic, GiefMe.GieftCollectionPrivate}>(GiefMe.GiefMePrivatePath, target: GiefMe.GiefMeStoragePath)
    }
}