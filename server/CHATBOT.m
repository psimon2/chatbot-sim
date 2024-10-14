CHATBOT ; ; 10/12/24 3:28pm
 quit
 
SETUP ;
 set ^%W(17.6001,"B","POST","chatbot/run","RUN^CHATBOT",22113377)=""
 set ^%W(17.6001,22113377,"AUTH")=2
 quit
 
RUN(arguments,body,result) ; post is in json format
 new x
 kill ^TMP($job)
 M ^BODY=body
 
 ; work out feature.
 s (json,z)=""
 f  s z=$o(body(z)) q:z=""  do
 .s json=json_body(z)
 .quit
 
 K b D DECODE^VPRJSON($name(json),$name(b),$name(err))
 s message=b("message")
 s sessionid=$get(b("sessionId"))
 
 s ^M=message
 ; Does this patient have a family member with a history of hypertension?
 for i=1:1:$l(message," ") do
 .set word=$$LC^LIB($$TR^LIB($p(message," ",i)," ",""))
 .if word="" quit
 .; check if any bits of the word are a term?
 .set q=1
 .s z=""
 .f  s z=$o(^MRTERMS(z)) q:z=""  if word[z s q=0
 .if q=1,'$data(^MRTERMS(word)) quit
 .set ^M($o(^M(""),-1)+1)=word
 .set answer=$r(2)+1
 .s ^M($o(^M(""),-1)+1)=$piece($text(FET1+answer),"; ",2,999)
 .set fet1=$piece($text(FET1+answer),"; ",2,999)_" (keyword: "_word_")"
 .set response="{""type"":""text"",""response"":"""_fet1_"""}"
 .s ^M($o(^M(""),-1)+1)=response
 .s ^TMP($job,1)=response
 .quit
 
 ; give me the patient's discharge letter with all medications highlighted 
 if $$LC^LIB(message)["highlight" do
 .kill rxnow
 .S ^T(sessionid,"highlight")=$Horolog
 .D NORRX(.rxnow)
 .s (i)=""
 .s now="{""text"":""Pt was prescribed "",""highlighted"":false},"
 .for  set i=$order(rxnow(i)) q:i=""  do
 ..s now=now_"{""text"":"""_rxnow(i)_""",""highlighted"":true},"
 ..quit
 .set now=$e(now,1,$l(now)-1)
 .kill rxprev
 .D NORRX(.rxprev)
 .set prev="{""text"":"" and was previously on "",""highlighted"":false},"
 .set i=""
 .for  set i=$o(rxprev(i)) q:i=""  do
 ..set prev=prev_"{""text"":"""_rxprev(i)_""",""highlighted"":true},"
 ..quit
 .set prev=$e(prev,1,$l(prev)-1)
 .s json="{""type"":""highlight"",""response"":["_now_","_prev_"]}"
 .s ^M($o(^M(""),-1)+1)=json
 .set ^TMP($j,1)=json
 .quit
 
 ; great, I have modified the text showing only prescribed meds, please insert into the patient's medical record
 set sure=0
 
 set lmsg=$$LC^LIB(message)
 if lmsg["insert" set sure=1
 if lmsg["save" set sure=1
 if lmsg["file" set sure=1
 if lmsg["update" set sure=1
 
 if sure=1 set response="{""type"":""text"",""response"":""You've not done any highlighting in this session""}",^TMP($J,1)=response
 if sure=1,$data(^T(sessionid,"highlight")) do
 .set response="{""type"":""text"",""response"":""Sure""}"
 .set ^TMP($J,1)=response
 .quit
 
 set chart=0
 if lmsg["graph" s chart=1
 if lmsg["chart" s chart=1
 if chart=1 do
 .set q=0
 .set freq=$$CHART1(lmsg)
 .set mdy=$$CHART2(lmsg)
 .if mdy="d",freq>20 do
 ..set txt="You specified days, you can only chart last 20 days"
 ..do RESPONSE(txt)
 ..s q=1
 ..quit
 .if mdy="m" do
 ..if freq>12 do
 ...set txt="You specified months, you can only chart the last 12 months"
 ...do RESPONSE(txt)
 ...set q=1
 ...quit
 .if mdy="y" do
 ..if freq>10 do
 ...set txt="You specified years, you can only chart the last 10 years"
 ...do RESPONSE(txt)
 ...set q=1
 ...quit
 ..quit
 .;
 .if q=0,freq>0,mdy'="" do
 ..set q=1
 ..set from=$$FROM(lmsg)
 ..D CHARTDATA(freq,mdy,from)
 ..quit
 .if q=0 do
 ..s response="{""type"":""text"",""response"":""You said you wanted me to draw a chart, but you did not tell me the last x months, days or years.  For example, show me a graph for the last 10 days""}"
 ..s ^TMP($j,1)=response
 ..quit
 .quit
  
 set id=$i(^ZAUDIT)
 set ^ZAUDIT(sessionid,id,1)=message ;request
 set ^ZAUDIT(sessionid,id,2)=$get(^TMP($j,1)) ; response
 set ^ZAUDIT(sessionid,id,3)=$get(un)
 
 I '$data(^TMP($j,1)) s response="{""type"":""text"",""response"":""Sorry, I did not understand you're question""}",^TMP($J,1)=response
 set result("mime")="text/html"
 set result=$na(^TMP($J))
 quit 1
 
FROM(lmsg) ;
 s h=""
 if lmsg["from" do
 .set date=$piece($p(lmsg,"from ",2)," ")
 .s h=$$DH^STDDATE(date)
 .quit
 quit h
 
CHARTDATA(freq,dmy,from) 
 set json=""
 s from=$get(from)
 if from="" set from=+$h
 S ^from=from
 if dmy="d" do
 .kill labels,data
 .set (data,labels)="",c=1
 .f i=(from-(freq-1)):1:from do
 ..s n=$r(10)
 ..set l=$$HD^STDDATE(i)
 ..set l=$p(l,".")_"/"_$p(l,".",2)
 ..s data(c)=n
 ..s labels(c)=l
 ..set c=c+1
 ..quit
 .s (c,labels,data)=""
 .f  s c=$o(labels(c),-1) q:c=""  do
 ..s label=labels(c)
 ..set n=data(c)
 ..s labels=labels_""""_label_""","
 ..s data=data_n_","
 ..quit
 .set labels=$e(labels,1,$l(labels)-1)
 .set data=$e(data,1,$l(data)-1)
 .set response="{""type"":""chart"",""chartData"":{""labels"":["_labels_"],""data"":["_data_"],""label"":""Number of Admissions""}}"
 .s ^TMP($j,1)=response
 .quit
 
 if dmy="m" do
 .set m(1)="Jan",m(2)="Feb",m(3)="Mar",m(4)="Apr",m(5)="May"
 .set m(6)="Jun",m(7)="Jul",m(8)="Aug",m(9)="Sep",m(10)="Oct"
 .set m(11)="Nov",m(12)="Dec"
 .kill months,x
 .set t=1
 .f i=from:-1 do  q:t>freq
 ..s date=$$HD^STDDATE(i)
 ..s month=$p(date,".",2),yr=$p(date,".",3)
 ..i '$d(x(yr,month)) set x(yr,month)="",months(t)=month_"/"_$e(yr,3,4),t=t+1
 ..quit
 .set (t,labels,data)=""
 .f  s t=$o(months(t)) q:t=""  do
 ..s n=$r(10),l=months(t)
 ..s labels=labels_""""_l_""","
 ..s data=data_n_","
 ..quit
 .s labels=$e(labels,1,$l(labels)-1)
 .s data=$e(data,1,$l(data)-1)
 .set response="{""type"":""chart"",""chartData"":{""labels"":["_labels_"],""data"":["_data_"],""label"":""Number of Admissions""}}"
 .s ^TMP($j,1)=response
 .quit
 
 if dmy="y" do
 .quit
 quit
 
RESPONSE(txt) 
 s response="{""type"":""text"",""response"":"""_txt_"""}"
 set ^TMP($j,1)=response
 quit
 
CHART2(lmsg) ;
 set z=""
 if lmsg["month" s z="m"
 if lmsg["day" s z="d"
 if lmsg["year" s z="y"
 quit z
 
CHART1(lmsg) 
 set q=0,z=""
 set freq=0
 if lmsg["last"!(lmsg["previous") do
 .; get the first number in the string.
 .set freq=$$FREQ(lmsg)
 .quit
 quit freq
 
FREQ(lmsg) ;
 new freq,i,n,q
 s freq=1,q=0
 for i=1:1:$length(lmsg," ") do  quit:q
 .s n=$p(lmsg," ",i)
 .i n?1n.n s freq=n,q=1
 .quit
 quit freq
 
NORRX(out) ;
 new total,rx
 s total=$r(5)+1
 s rx(1)="paracetamol"
 s rx(2)="omeprazole"
 s rx(3)="amoxycillin"
 s rx(4)="benzoyl"
 s rx(5)="prednisolone"
 f i=1:1:total s out(i)=rx(i)
 quit
 
FET1 ;
 ; No, I could not find anything in the record
 ; Yes, its in their record
 quit
 
WORDS ;
 K ^MRWORDS
 set f="/tmp/wordlist.txt"
 close f
 o f:(readonly)
 f  u f r str quit:$zeof  do
 .use 0 w !,str
 .set str=$$LC^LIB(str)
 .S ^MRWORDS(str)=""
 .quit
 close f
 quit
 
MRTERMS ;
 K ^MRTERMS
 set f="/tmp/mr-terms.txt"
 close f
 open f:(readonly)
 for  use f r str q:$zeof  do
 .use 0 ; w !,str
 .set term=$p($p(str,":")," ",2)
 .set term=$$TR^LIB(term,"-","")
 .set term=$$TR^LIB(term,",","")
 .set root=$p(term,"/")
 .I $length(root)<2 quit
 .for i=2:1:$l(term,"/") do
 ..set ^MRTERMS($$LC^LIB(root_$p(term,"/",i)))=""
 ..quit
 .w !,term
 .S ^MRTERMS($$LC^LIB(root))=""
 .quit
 close f
 quit
