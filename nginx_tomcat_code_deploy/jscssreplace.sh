#!/bin/bash
shpath=$1
jsversion=$2
cd ${shpath}
jsarray=(
	'/js/aboutOrderInterface'
	'/js/indexComm'
	'/js/map'
	'/js/md5'
	'/js/msgNav'
	'/js/myProduce'
	'/js/ort'
	'/js/OstPaths'
	'/js/pageUtils'
	'/js/productDetail'
	'/js/resultDom'
	'/js/setup'
	'/js/shopcarList'
	'/js/sysutil'
	'/js/tuodong'
	'/js/validate-methods'
	'/js/page/accoutSecurity'
	'/js/page/ageInformation_l'
	'/js/page/basePriceForm'
	'/js/page/basePriceList'
	'/js/page/buyModuleDetail'
	'/js/page/buyModuleList'
	'/js/page/contactInfo'
	'/js/page/customAddProducts'
	'/js/page/detecForm'
	'/js/page/detecList'
	'/js/page/detIndex'
	'/js/page/emailChange'
	'/js/page/evaluateList'
	'/js/page/index'
	'/js/page/invitCodeForm'
	'/js/page/invitCodeList'
	'/js/page/invoiceList'
	'/js/page/isPayPassWordUpdata'
	'/js/page/modifyPassword'
	'/js/page/moduleList'
	'/js/page/myAssets'
	'/js/page/MyShoppingCart'
	'/js/page/newsList'
	'/js/page/orderBargainForm'
	'/js/page/orderBargainList'
	'/js/page/orderList'
	'/js/page/orderPayList'
	'/js/page/orderRecvList'
	'/js/page/organizationList'
	'/js/page/orgAuthenChange'
	'/js/page/orgInfo'
	'/js/page/orgList'
	'/js/page/payInfo'
	'/js/page/proBas'
	'/js/page/proCenter'
	'/js/page/productForm'
	'/js/page/productList'
	'/js/page/qkBasePriceList'
	'/js/page/quickAddProducts'
	'/js/page/quickOrder'
	'/js/page/sampleRecvList'
	'/js/page/submitOrder'
	'/js/page/talk'
	'/js/page/enp/accoutSecurity'
	'/js/page/enp/addList'
	'/js/page/enp/certCmList'
	'/js/page/enp/contactInfo'
	'/js/page/enp/emailChange'
	'/js/page/enp/enpInfo'
	'/js/page/enp/enpMessage'
	'/js/page/enp/lookingorder'
	'/js/page/enp/modifyPassword'
	'/js/page/enp/myAssets'
	'/js/page/enp/orderList'
	'/js/page/enp/ordEvaluate'
	'/js/page/enp/payPasswordChange'
	'/js/page/enp/sendAddress'
	'/js/page/index/acountActiveMsg'
	'/js/page/index/act'
	'/js/page/index/activation'
	'/js/page/index/customAddProducts'
	'/js/page/index/customEdit'
	'/js/page/index/detectionIndex'
	'/js/page/index/enpAccount'
	'/js/page/index/enpAgreement'
	'/js/page/index/enpAuthentication'
	'/js/page/index/enpContact'
	'/js/page/index/enpImproveInformation'
	'/js/page/index/error'
	'/js/page/index/forgetPassword'
	'/js/page/index/generate'
	'/js/page/index/index'
	'/js/page/index/isokEmail'
	'/js/page/index/map'
	'/js/page/index/notPass'
	'/js/page/index/notPassMsg'
	'/js/page/index/orgAccount'
	'/js/page/index/orgAuthentication'
	'/js/page/index/orgContact'
	'/js/page/index/productDisplay'
	'/js/page/index/productEdit'
	'/js/page/index/proPreview'
	'/js/page/index/quickAddProducts'
	'/js/page/index/review'
	'/js/page/index/setNewPassword'
	)
cssarray=(
	'/css/index/enpMap'
	'/css/commomModel'
	'/css/contact_l'
	'/css/enpcomstyle'
	'/css/enpMap'
	'/css/global'
	'/css/homeModule'
	'/css/indexCommom'
	'/css/login_l'
	'/css/mesg'
	'/css/orderStyle'
	'/css/orgOrder'
	'/css/phoneCard'
	'/css/ShoppingCar'
	'/css/talk'
	)
minjsarray=(
	'/data/DataDict'
	'/data/IndustryAgrs'
	'/data/Pollutants'
	'/data/SubAreas'
	)
dirarray=(
	'./modules/foreignDoor'
	'./WEB-INF/views/modules/ostesting'
	'./WEB-INF/views/include/enpHeader.jsp'
	'./WEB-INF/views/include/header.jsp'
	)
for n in ${dirarray[@]}
do
	for i in ${jsarray[@]}
	do
		sed -i "s#${i}.js#${i}_${jsversion}.min.js#" `grep ${i}.js -rl ${n}`
	done;
	for i in ${cssarray[@]}
	do
		sed -i "s#${i}.css#${i}_${jsversion}.min.css#" `grep ${i}.css -rl ${n}`
	done;
	for i in ${minjsarray[@]}
	do
		sed -i "s#${i}.min.js#${i}_${jsversion}.min.js#" `grep ${i}.min.js -rl ${n}`
	done;
done