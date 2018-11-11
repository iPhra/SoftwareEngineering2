open util/boolean

----------Signatures----------
sig Email {}
sig FC {}
sig PIVA {}

abstract sig Account {
	email: one Email
} 

sig PrivateAccount extends Account {
	fc: one FC
} 

sig ThirdPartyAccount extends Account {
	piva: one PIVA,
	accessedUsers: set PrivateAccount, //users that approved a single request at least once
	subscriptions: set PrivateAccount //users to whom the third party is subscribed
}



----------Facts----------
fact uniquenessAndExistentiality {
	no disj a1, a2: Account | a1.email = a2.email //there are no accounts with the same email 
	no disj a1, a2: PrivateAccount | a1.fc = a2.fc //there are no private accounts with the same FC
	no disj u1,u2: ThirdPartyAccount | u1.piva = u2.piva //there are no third parties with the same PIVA
	no e: Email | no a: Account | a.email = e //all emails are linked to at least one account
	no f: FC | no p: PrivateAccount | p.fc = f //all fc are linked to at least one private account
	no p: PIVA | no t: ThirdPartyAccount | t.piva = p //all piva are linked to at least one third party
}

fact subIfAccessed {
	all p: PrivateAccount | all t: ThirdPartyAccount | p in t.subscriptions implies p in t.accessedUsers //a third party can be subscribed to a user he only accessed at least once
}



----------Predicates----------
pred show {}

run show for 5


