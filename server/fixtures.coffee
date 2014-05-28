insertData = (data, collection) ->
  if collection.find().count() is 0
    for _id, object of data
      object._id = _id
      object.isNew = false
      collection.insert(object)
    return true

share.loadFixtures = ->
  now = new Date()
  lastWeek = new Date(now.getTime() - 7 * 24 * 3600 * 1000)
  users = {}
  userinfos = [
    {
      name: "Hjort, Jens Johan"
      party: "H"
    }
    {
      name: "Skogman, Anni"
      party: "FRP"
    }
    {
      name: "Lind, Rolleiv"
      party: "H"
    }
    {
      name: "Barman-Jenssen, Knut"
      party: "H"
    }
    {
      name: "Echroll, Lars"
      party: "H"
    }
    {
      name: "Fossbakk, Frid Einarsdotter"
      party: "H"
    }
    {
      name: "Larsen, Bodil Ridderseth"
      party: "H"
    }
    {
      name: "Mæland, Magnus"
      party: "H"
    }
  ]
  for userinfo in userinfos
    splinters = userinfo.name.split(",")
    name = splinters.reverse().join(" ").trim()
    _id = name.replace(/[^\w]/g, "")
    users[_id] =
      _id: _id
      profile:
        name: name
        party: userinfo.party
        locale: "no"
        image: "/fixtures/" + _id + ".jpg"
      emails: [
        {
          address: _id.toLowerCase() + "@meetings.me"
          verified: true
        }
      ]
      services:
        password: #123123
          srp:
            identity: "yE3SDLstoyKgho6aw"
            salt: "2KaD5ByuLFiB9D67m"
            verifier: "a9cd2d77478f4538a31651af4e9030a2e39da29ad335725054dcef3efd256caab0387964920bb924eddd17f8b20498a109e652ace08e514ed16cc0e38e352cde5edae0f56fae6feb3f37e4afee5ca96fb473fad9ab70d5a5307e662a377e79c9e4aa99e4fd5983d7ca2df98c07fd631f3a693da42ad92249b3b9fae36f7e8e40"
      createdAt: lastWeek
  allUsersIds = []
  for user in users
    allUsersIds.push(user._id)
  insertData(users, Meteor.users)

  meetings =
    Kommunestyret:
      name: "Kommunestyret, 28.05.2014 0900"
    Forretningsutvalget:
      name: "Forretningsutvalget, 02.06.2014 1200"
    Byradet:
      name: "Byrådet, 19.06.2014 1200"

  insertData(meetings, share.Meetings)

  saker =
    KONTROLLUTVALGSSAK:
      name: "KONTROLLUTVALGSSAK 22/14 - BRANN OG REDNING	"
      number: "75/14"
      maximumDuration: 2.0 * 60 * share.minute
      position: 1
      meetingId: "Kommunestyret"
    REGULERINGSPLAN:
      name: "PLAN- 1783- REGULERINGSPLAN FOR NEDRE VANGBERG, EIEND. 118/24 M.FL SAKSFREMLEGG TIL VEDTAK"
      number: "76/14"
      maximumDuration: 15 * share.minute
      position: 2
      meetingId: "Kommunestyret"
    BOLIGBYGG:
      name: "PLAN -1762- NYTT BOLIGBYGG VED ST.ELISABETH"
      number: "77/14"
      maximumDuration: 1.5 * 60 * share.minute
      position: 3
      meetingId: "Kommunestyret"
    FourthSak:
      name: "Fourth sak"
      number: "04/14"
      position: 1
      meetingId: "Forretningsutvalget"
    FifthSak:
      name: "Fifth sak"
      number: "05/14"
      position: 2
      meetingId: "Forretningsutvalget"
    SixthSak:
      name: "Sixth sak"
      number: "06/14"
      position: 1
      meetingId: "Byradet"

  insertData(saker, share.Saker)

  talks =
    JensJohanHjortKONTROLLUTVALGSSAKTalk:
      sakId: "KONTROLLUTVALGSSAK"
      userId: "JensJohanHjort"
      position: 1
    AnniSkogmanKONTROLLUTVALGSSAKTalk:
      sakId: "KONTROLLUTVALGSSAK"
      userId: "AnniSkogman"
      position: 2
    BodilRiddersethLarsenREGULERINGSPLANTalk:
      sakId: "REGULERINGSPLAN"
      userId: "BodilRiddersethLarsen"
      position: 1
    FridEinarsdotterFossbakkREGULERINGSPLANTalk:
      sakId: "REGULERINGSPLAN"
      userId: "FridEinarsdotterFossbakk"
      position: 2
    KnutBarmanJenssenREGULERINGSPLANTalk:
      sakId: "REGULERINGSPLAN"
      userId: "KnutBarmanJenssen"
      position: 3
    LarsEchrollREGULERINGSPLANTalk:
      sakId: "REGULERINGSPLAN"
      userId: "LarsEchroll"
      position: 4

  insertData(talks, share.Talks)

  replies =
    JensJohanHjortKONTROLLUTVALGSSAKTalkReplyByBodilRiddersethLarsen:
      talkId: "JensJohanHjortKONTROLLUTVALGSSAKTalk"
      userId: "BodilRiddersethLarsen"
      position: 1
    JensJohanHjortKONTROLLUTVALGSSAKTalkReplyByKnutBarmanJenssen:
      talkId: "JensJohanHjortKONTROLLUTVALGSSAKTalk"
      userId: "KnutBarmanJenssen"
      position: 2

  insertData(replies, share.Replies)

  AccountsLoginServiceConfigurationData = [
    {
      service: "google",
      clientId: Meteor.settings.public.google.clientId,
      secret: Meteor.settings.google.secret
    }
  ]
  insertData(AccountsLoginServiceConfigurationData, Accounts.loginServiceConfiguration)
