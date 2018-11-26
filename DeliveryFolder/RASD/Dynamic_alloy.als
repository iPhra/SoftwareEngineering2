open util/boolean
open util/integer

----------Signatures----------
sig Email {}
sig FC {}
sig PIVA {}

abstract sig Status {}
one sig Approved extends Status {}
//for a single request, pending means that the request is created but not in the pending list of
//the target user, or that it is in the pending list of the user, so waiting for him to approve it
//for a group request, pending means that the system has yet to evaluate it
one sig Pending extends Status {}
one sig Declined extends Status {}

//health parameter, in this case used as a search parameter and not as a requested data type
abstract sig Parameter {
value: one Int
}{value>0}

sig Age extends Parameter {}
sig Height extends Parameter {}
sig BPM extends Parameter {}

abstract sig Request {
	fromEmail: one Email, //email of the third party
	status: one Status,
	subscribing: one Bool
} 

//instance of a single request, a request can be pending, and then can be accepted or declined. For each of these phases, there is a different instance of request
sig SingleRequest extends Request {
	toEmail: lone Email, 
	toFC: lone FC,
	fromPIVA: one PIVA, //for single requests the target user should know the PIVA of the third party as well
} {
	#toEmail = 1 iff #toFC = 0 //the request can be done either through the email or the fc, not both of them
}

//group requests don't have to be accepted by a user, so the S2B doesn't need the email and fc of the target, neither the PIVA of the third party since it knows the email already
sig GroupRequest extends Request {
	condition: one Parameter, //condition expressed in the anonymous request, eg: "Data of all the people whose age is 30"
} 

abstract sig Account {
	email: one Email
} 

sig PrivateAccount extends Account {
	fc: one FC,
	age: one Age,
	height: one Height, //in cm
	bpm: one BPM, //heart rate
	pendingRequests: set SingleRequest,
	approvedRequests: set SingleRequest,
	declinedRequests: set SingleRequest
} {
	//all lists are disjoint one another
	#(pendingRequests & approvedRequests) = 0 
	#(approvedRequests & declinedRequests) = 0
	#(pendingRequests & declinedRequests) = 0
}

sig ThirdPartyAccount extends Account {
	piva: one PIVA,
	accessedUsers: set PrivateAccount, //users that approved a request at least once
	subscriptions: set PrivateAccount //single users to whom the third party is subscribed
}



----------Facts----------
fact existentiality {
	no e: Email | no a: Account | a.email = e //all emails are linked to at least one account
	no f: FC | no p: PrivateAccount | p.fc = f //all fc are linked to at least one private account
	no p: PIVA | no t: ThirdPartyAccount | t.piva = p //all piva are linked to at least one third party
	no a1: PrivateAccount, a2: ThirdPartyAccount | a1.email = a2.email //the same email can't be used by both a private account and third party, emails should be unique but this constraint is relaxed in this model
	no a: Age | no p: PrivateAccount | p.age = a //all ages are linked to at least one account
	no h: Height | no p: PrivateAccount | p.height = h //all heights are linked to at least one account
	no b: BPM | no p: PrivateAccount | p.bpm = b //all heart rates are linked to at least one account
	no disj a1,a2 : Age | a1.value = a2.value //value of two different age entities must be different as well
}

fact reqProperties {
	//all requests contain the email of the sender
	//the sender is not unqiue in order to represent dynamicity, since there will be an entity before and after a request has been approved/declined, and those entity have the same email and PIVA
	all r: Request | some a: ThirdPartyAccount | 
		(a.email = r.fromEmail)
}

fact singleRequestProperties {
	//all single requests contain either the email or fc of the receiver, who is unique
	all r: SingleRequest | some a: PrivateAccount | (a.email = r.toEmail or r.toFC = a.fc) 

	//single requests must also contain the piva of the sender, since the receiving user should know it
	all r: SingleRequest | some a: ThirdPartyAccount | a.piva = r.fromPIVA

	//if a request is in one of the user's list, then that user is the receiver of that request
	all r: SingleRequest | all p:PrivateAccount | r in (p.pendingRequests + p.approvedRequests + p.declinedRequests) implies (p.email = r.toEmail or r.toFC = p.fc)
	
	all r: SingleRequest | 
		(r.status in Approved iff one p: PrivateAccount | r in p.approvedRequests) and //if a request is approved, then there is exactly one account that has it in the approved list
		(r.status in Declined iff one p: PrivateAccount | r in p.declinedRequests) and //if a request is declined, then there is exactly one account that has it in the declined list
		((one p: PrivateAccount | r in p.pendingRequests) implies r.status in Pending) //if a request is in the pending list of one account, then it's pending (but not viceversa, it can be pending but not submitted yet)
}

//a group request is approved only if there exist at least 3 private account that match the condition
fact groupRequestProperties {
	all r: GroupRequest | r.status in Approved implies 
		let x = {p: PrivateAccount | 
			(r.condition in Age and p.age.value=r.condition.value) or
			(r.condition in Height and p.bpm.value=r.condition.value) or
			(r.condition in BPM and p.bpm.value=r.condition.value)} |
		#x > 3 //this is a restriction, the actual value should be 1000
}

//a request is approved or declined only if it was previously pending
fact pendingRequests {
	all r: Request | r.status in (Approved + Declined) implies 
		(one r': Request | r'.status in Pending and 
			((r in GroupRequest and groupReqUnchanged[r,r']) or
			(r in SingleRequest and singleReqUnchanged[r,r'])))
}

fact accessAndSubscriptions {
	//a third party has access to a private account's data if and only if one of his request was accepted
	all t: ThirdPartyAccount | all p: PrivateAccount |  
		p in t.accessedUsers iff  (some r: SingleRequest | 
				(r.fromPIVA = t.piva and r.fromEmail = t.email) and
				r in p.approvedRequests)

	//a third party is subscribed to a private account if and only if his request of subscription was accepted
	all t: ThirdPartyAccount | all p: PrivateAccount |  
		p in t.subscriptions iff (some r: SingleRequest | 
				(r.fromPIVA = t.piva and r.fromEmail = t.email) and
				(r.subscribing in True) and
				(r in p.approvedRequests))
}



----------Predicates----------
//predicate used to check that two group requests haven't changed
pred groupReqUnchanged[r,r': GroupRequest] {
	r'.condition = r.condition
	r'.fromEmail = r.fromEmail
	r'.subscribing = r.subscribing
}

//predicate used to check that two single requests haven't changed, apart from the status
pred singleReqUnchanged[r,r': SingleRequest] {
	r'.toEmail = r.toEmail
	r'.fromEmail = r.fromEmail
	r'.fromPIVA = r.fromPIVA
	r'.toFC = r.toFC
	r'.subscribing = r.subscribing
}

//predicate used to check that two private accounts generalities haven't changed
pred accUnchanged[a,a': PrivateAccount] {
	a'.fc = a.fc
	a'.email = a.email
}

//accept a group request, thus defining a world in which the conditions expressed in groupRequestConditions hold
pred acceptGroupRequest[r,r': GroupRequest] {
	//precondition
	r.status in Pending
	
	//postcondition
	groupReqUnchanged[r,r']
	r'.status in Approved
}

//decline a group request, thus defining a world in which the conditions expressed in groupRequestConditions do not hold
pred declineGroupRequest[r,r': GroupRequest] {
	//precondition
	r.status in Pending

	groupReqUnchanged[r,r']
	r'.status in Declined
}

//add a pending single request
pred addSingleRequest[r: SingleRequest, a,a': PrivateAccount] {
	//precondition
	r not in a.pendingRequests
	
	//postcondition
	a'.fc = a.fc
	a'.email = a.email
	a'.pendingRequests = a.pendingRequests + r
	a'.approvedRequests = a.approvedRequests
	a'.declinedRequests = a.declinedRequests
}

//accept a pending single request
pred acceptSingleRequest[r,r': SingleRequest, a,a': PrivateAccount] {
	//precondition
	r in a.pendingRequests
	r' not in (a.approvedRequests + a.declinedRequests + a.pendingRequests)

	//postcondition
	singleReqUnchanged[r,r']
	accUnchanged[a,a']
	a'.pendingRequests = a.pendingRequests - r
	a'.approvedRequests = a.approvedRequests + r'
	a'.declinedRequests = a.declinedRequests
}

//decline a pending single request
pred declineSingleRequest[r,r': SingleRequest, a,a': PrivateAccount] {
	//precondition
	r in a.pendingRequests
	r' not in (a.approvedRequests + a.declinedRequests + a.pendingRequests)

	//postcondition
	singleReqUnchanged[r,r']
	accUnchanged[a,a']
	a'.pendingRequests = a.pendingRequests - r
	a'.approvedRequests = a.approvedRequests
	a'.declinedRequests = a.declinedRequests +r'
}

//add a pending request and then accept it
pred showSingleAccept[r,r': SingleRequest, a,a',a'': PrivateAccount, t: ThirdPartyAccount] {
	addSingleRequest[r, a,a']
	acceptSingleRequest[r,r',a',a'']
}

//add a pending request and then decline it
pred showSingleDecline[r,r': SingleRequest, a,a',a'': PrivateAccount, t: ThirdPartyAccount] {
	addSingleRequest[r, a,a']
	declineSingleRequest[r,r',a',a'']
}



----------Assertions----------
//a third party is subscribed to a user if he also accessed that user, at least once
assert subscriptionIfAccess {
	all t: ThirdPartyAccount | all p: t.subscriptions | p in t.accessedUsers
}



check subscriptionIfAccess
run declineGroupRequest for 4 but 0 SingleRequest, 1 ThirdPartyAccount, 2 GroupRequest
run acceptGroupRequest for 5 but 0 SingleRequest, 1 ThirdPartyAccount, 2 GroupRequest
run showSingleAccept for 4 but 0 GroupRequest, 1 ThirdPartyAccount,  2 SingleRequest
