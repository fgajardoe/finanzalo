library(tidyverse)
library(ggrepel)
library(readxl)
library(reshape2)
library(plotly)



# functions
getMonthStr=function(yyyymmdd){
	mm=yyyymmdd %>% substr(5,6) %>% as.character

	m.dict=c("01"="Enero",
		 "02"="Febrero",
		 "03"="Marzo",
		 "04"="Abril",
		 "05"="Mayo",
		 "06"="Junio",
		 "07"="Julio",
		 "08"="Agosto",
		 "09"="Septiembre",
		 "10"="Octubre",
		 "11"="Noviembre",
		 "12"="Diciembre")
	return(m.dict[mm])

}




# main

args=commandArgs(T)

inputData=as.character(args[1]) #"transacciones-1-enero-25-marzo-2024.txt"
outReport=paste0(inputData,".report.pdf")
outReportHTML=paste0(inputData,".report.html")
input="excel_list"

if(input=="txt"){


	col.widths=c(11,8,9,8,22,1,3,45,1,8,5)
	col.names=c("Cuenta Corriente","Fecha del Movimiento","Codigo de Transaccion","Serial","Monto del Movimiento","Signo","Codigo de Sucursal","Descripcion del Movimiento","Tipo de Transaccion","Fecha de Emision","Numero de Folio")

	d=read.fwf(inputData,widths=col.widths) %>% tibble
	colnames(d)=col.names




	# tabla util para ver cargos(C) abonos(A) y saldos(S)
	d %>% group_by(`Tipo de Transaccion`) %>% summarise(Monto_total=sum(`Monto del Movimiento`))


	#saldo_contable=d %>% filter(`Tipo de Transaccion`=="S", `Descripcion del Movimiento`=="SALDO CONTABLE                               ")  %>% select(`Codigo de Transaccion`,`Monto del Movimiento`,Signo) %>% mutate(`Monto del Movimiento`=ifelse(Signo=="+",`Monto del Movimiento`,`Monto del Movimiento`*-1)) %>% distinct() %>% pull(`Monto del Movimiento`)

	
	#title=paste0("Saldo: ",format(saldo_contable, nsmall=1, big.mark=",")," CLP (",format(Sys.time(), "%e/%b/%Y"),")")
	title=inputData

	pdf(outReport,width=14,height=7)
	# plot bonito resumiendo toda mi situacion bancaria
	pal=c(A="#1a9641",C="#d7191c",S="#92c5de")
	d %>% mutate(`Monto del Movimiento`=ifelse(Signo=="+",`Monto del Movimiento`,`Monto del Movimiento`*-1)) %>% ggplot(aes(x=`Fecha del Movimiento`,y=`Monto del Movimiento`,colour=`Tipo de Transaccion`))+geom_point(alpha=0.5)+theme_classic()+geom_text_repel(aes(label=`Descripcion del Movimiento`,size=`Monto del Movimiento`),max.overlaps=35)+scale_color_manual(values=pal)+ggtitle(title)
	dev.off()


}
if(input=="excel"){
	############
	#con excel


	d.xls=read_excel(inputData,range="B27:G127")
	colnames(d.xls)=c("Fecha","Descripcion","Canal o Sucursal","Cargos (CLP)", "Abonos (CLP)", "Saldo (CLP)")

	d.xls.long=d.xls %>% select(Fecha,`Cargos (CLP)`, `Abonos (CLP)`, `Saldo (CLP)`,`Descripcion`) %>% melt %>% tibble

	d.xls.long=d.xls.long %>% mutate(Fecha.2=as.numeric(format(as.Date(Fecha, format = "%d/%m/%Y"), "%Y%m%d")))



	d.xls.long %>% mutate(word_size=abs(value)) %>% ggplot(aes(y=value,x=Fecha.2,colour=variable))+geom_point()+geom_line()+theme_classic()+theme(axis.text.x=element_text(angle=90))+geom_text_repel(aes(label=`Descripcion`,size=word_size),max.overlaps=5)

}
if(input=="excel_list"){
	
	files=read.table(inputData,col.names=c("path")) %>% tibble %>% pull(path)
	
	data.lst=vector(mode="list", length=length(files))
	names(data.lst)=files

	for(f in files){
		d.xls=read_excel(f,range="B27:G127")
		colnames(d.xls)=c("Fecha","Descripcion","Canal o Sucursal","Cargos (CLP)", "Abonos (CLP)", "Saldo (CLP)")
		d.xls.long=d.xls %>% select(Fecha,`Cargos (CLP)`, `Abonos (CLP)`, `Saldo (CLP)`,`Descripcion`) %>% melt %>% tibble
		d.xls.long=d.xls.long %>% mutate(Fecha.2=as.numeric(format(as.Date(Fecha, format = "%d/%m/%Y"), "%Y%m%d")))
		data.lst[[f]]=d.xls.long
	}

	data=do.call("rbind",data.lst)
	nrows_before=NROW(data)
	print("removing redundant rows")
	data=data %>% distinct
	nrows_after=NROW(data)
	nrows_removed=nrows_before-nrows_after
	print(paste0(nrows_removed," redundant rows removed."))

	data=data %>% mutate(Monto=value,Tipo=variable)

	data.saldos=data %>% filter(variable=="Saldo (CLP)")

	pdf(outReport,width=14,height=7)
	pal=c("Abonos (CLP)"="#1a9641","Cargos (CLP)"="#d7191c","Saldo (CLP)"="#92c5de")
	year=data %>% pull(Fecha.2)%>% max %>% substr(1,4) %>% as.numeric 
	nextyear=year+1
	xmax=nextyear %>% paste0(.,"0000") %>% as.numeric
	xlimits=c(0,xmax)
	ylimits=c(-2000000,3000000)
        p=data %>%
		mutate(word_size=abs(value),Label=ifelse(variable=="Saldo (CLP)","",Descripcion)) %>% 
		ggplot(aes(y=value,x=Fecha.2,colour=variable))+
		geom_point(size=0.8)+
		theme_classic()+theme(axis.text.x=element_text(angle=90))+
		geom_text_repel(aes(label=Label,size=word_size),max.overlaps=15)+
#		geom_text(aes(label=`Descripcion`,size=6,angle=45))+
		scale_colour_manual(values=pal)+
		geom_line(data=data.saldos,aes(x=Fecha.2,y=value,colour=variable),linetype = "dashed",alpha=0.5)+geom_hline(yintercept=0,linetype="dashed",colour="grey",alpha=0.8)+ylab("Monto (CLP)")+xlab("Fecha (yyyymmdd)")+
		ggtitle(inputData)+ylim(ylimits) #+xlim(xlimits)
	show(p)
	dev.off()

	data.saldos=data.saldos %>% mutate(Monto=value,Tipo=variable)
	data=data %>% filter(variable!="Saldo (CLP)")


	#month names
	ene=paste0(year,"0115")
	feb=paste0(year,"0215")
	mar=paste0(year,"0315")
	abr=paste0(year,"0415")
	may=paste0(year,"0515")
	jun=paste0(year,"0615")
	jul=paste0(year,"0715")
	ago=paste0(year,"0815")
	sep=paste0(year,"0915")
	oct=paste0(year,"1015")
	nov=paste0(year,"1115")
	dic=paste0(year,"1215")


	maxValue=data %>% filter(is.na(value)==F)%>% pull(value) %>% max %>% as.numeric
	months.y=maxValue+maxValue*0.1
	all_months_str=c("Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre")
	months=tibble(Mes=all_months_str,Fecha=as.numeric(c(ene,feb,mar,abr,may,jun,jul,ago,sep,oct,nov,dic)),y=rep(months.y,12))

	lastAvailableDate=data %>% pull(Fecha.2) %>% max
	months=months %>% filter(Fecha<lastAvailableDate)

	# plot puntos
        p.point=data %>% mutate(size=abs(value)) %>%
		ggplot(aes(y=Monto,x=Fecha.2,colour=Tipo,label=Descripcion))+
		geom_point(size=0.95)+
		#geom_point(aes(size=size))+
		theme_classic()+
		theme(axis.text.x=element_text(angle=90))+
		scale_colour_manual(values=pal)+
		geom_line(data=data.saldos,aes(x=Fecha.2,y=Monto,colour=Tipo),linetype = "dashed",alpha=0.5)+geom_hline(yintercept=0,linetype="dashed",colour="grey",alpha=0.8)+ylab("Monto (CLP)")+xlab("Fecha (yyyymmdd)")+
		annotate("text", x = months$Fecha, y = months$y,
           label = months$Mes, color = "#404040", size = 4,  angle = 45)+
		ggtitle(inputData) #+
		#ylim(ylimits) #+xlim(xlimits)

	# plot barras
	data=data %>% mutate(Month=getMonthStr(Fecha.2)) %>% mutate(Month=factor(Month,levels=c(all_months_str))) %>% mutate(Tipo=ifelse(Descripcion=="Transferencia Desde Linea De Credito","Linea de Sobregiro (CLP)",as.character(Tipo)))
	months.v=data %>% filter(Month %in% months) %>% unique 
	pal.bar=pal
	pal.bar["Linea de Sobregiro (CLP)"]="#fdae61"
	p.bar=data %>% ggplot(aes(x=Month,y=Monto,fill=Tipo,label=Descripcion))+geom_bar(stat="identity",position="dodge",width=0.8)+theme_classic()+scale_fill_manual(values=pal.bar)



	p.bar.plotly=ggplotly(p.bar)
	p.point.plotly=ggplotly(p.point)


	p.plotly=subplot(p.point,p.bar,nrows=2)

	library(htmlwidgets)
	library(rmarkdown)
	saveWidget(p.plotly, outReportHTML,selfcontained=F)

}


save.image("finanzalo.last_run.RData")
