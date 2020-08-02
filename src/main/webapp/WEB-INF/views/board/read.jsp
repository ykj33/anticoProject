<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>

<head>
	<title>이쁜이들 마스크</title>
	<%@ include file="../com/header.jsp"%>
	<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
	<script>
		document.addEventListener("DOMContentLoaded", () => {

			// local data
			let data = { 
				user: '${login.email }',
				option: { 
					goods_no:'${dto.goods_no }'
					, goods_color: '${dto.goods_colors[0].goods_color }'
					, goods_size: '${dto.goods_sizes[0].goods_size }'
					, goods_untpc: '${dto.goods_sizes[0].goods_untpc }' 
					},
				cart: []
			};

			let btnCollapse = document.getElementById('btnCollapse');
			let hide = document.getElementById('hide');
			let option = document.getElementById('option');
			let list = document.getElementById('list');
			let totalPrice = document.getElementById('totalPrice');

			// 구매 버튼 / 장바구니 버튼 클릭시.
			btnCollapse.addEventListener("click", () => {

				let idx = data.cart.length;
				// 장바구니에 중복되는 상품이 있는지 확인함.
				for (let i = 0; i < idx; i++) {
					const arr = data.cart[i];
					if(data.option.goods_no == arr.goods_no
					&& data.option.goods_color == arr.goods_color
					&& data.option.goods_size == arr.goods_size) {
						alert('같은 상품이 존재 합니다.');
						window.scrollTo(0, 0);
						$('.collapse').collapse('show');
						return;
					};
				}

				// 새로운 상품 data
				let newCart = {
					cart_id : 0,
					email : '${login.email }',
					goods_no : data.option.goods_no,
					goods_img : '${dto.goods_img }',
					goods_nm : '${dto.goods_nm }',
					goods_color : data.option.goods_color,
					goods_size : data.option.goods_size,
					goods_qtys : 1,
					goods_untpc : data.option.goods_untpc
				};

				// ajax 장바구니 추가.
				axios({
					method: 'post',
					url: '/board/addcart',
					headers: {
						"Content-Type": "application/json",
						"X-HTTP-Method-Override": "POST"
					},
					data: JSON.stringify(newCart),
					responseType: 'text'
				}).then(function (response) {

					console.log('상품등록 ajax response >>', response);

					if(response.data) {
						// 업데이트 된 list를 localdata data.cart에 추가한다.
						data.cart = response.data;

						let str = ''

						for (let i = 0; i < data.cart.length; i++) {
							const cart = data.cart[i];

							// 동적 테이블 생성
							str += ''
							+'<div class="row ml-4 mb-2 text-center">'
							+	'<div class="col-md-1"><img src="/displayfile?img_name='+cart.goods_img+'" width="60px" height="60px"></div>'
							+	'<div class="col-md-5">'+cart.goods_nm+'</div>'
							+	'<div class="col-md-1">'+cart.goods_size+'</div>'
							+	'<div class="col-md-1">'+cart.goods_color+'</div>'
							+	'<div class="col-md-2 line">'
							+		'<div class="row">'
							+			'<div class="col"><p class="btn btn-block minus">-</p></div>'
							+			'<div class="col mt-2"><p class="qtys">'+cart.goods_qtys+'</p></div>'
							+			'<div class="col"><p class="btn btn-block plus text-muted">+</p></div>'
							+		'</div>'
							+	'</div>'
							+	'<div class="col-md-2 price" data-u-price="'+cart.goods_untpc+'">'+numberWithCommas(cart.goods_untpc * cart.goods_qtys)+'</div>'
							+'</div>';
							
						}

						list.innerHTML += str;
						// 장바구 아이템의 총액을 계산후 표시.
						cartTotalPrice();
					}
					
				});
				
				// 장바구 아이템의 총액을 계산후 표시.
				cartTotalPrice();

				// 장바구니 열림
				window.scrollTo(0, 0);
				$('.collapse').collapse('show');
			});

			// 장바구니 창에 X표시를 클릭시.
			hide.addEventListener('click', () => {
				$('.collapse').collapse('hide');
			});

			// 장바구니 리스트의 버튼들을 클릭시.
			list.addEventListener('click', (event) => {
				let element = event.target;
				let strClass = element.getAttribute('class');
				let qtysRow = element.parentNode.parentNode;
				let	qtys = qtysRow.getElementsByClassName('qtys')[0];
				let price = qtysRow.parentNode.parentNode.getElementsByClassName('price')[0];
				let data_u_price = price.getAttribute('data-u-price');
				let strNum = qtys.innerHTML;
				strNum = strNum.replace(',', '');

				if(strClass.indexOf('minus') > -1) {
					qtys.innerHTML = Number(strNum) - 1;
					price.innerHTML = numberWithCommas((Number(strNum) - 1) * Number(data_u_price));
					if(qtys.innerHTML == '0') {
						let row = qtysRow.parentNode.parentNode;
						row.remove();
					}
				}

				if(strClass.indexOf('plus') > -1) {
					qtys.innerHTML = Number(strNum) + 1;
					price.innerHTML = numberWithCommas((Number(strNum) + 1) * Number(data_u_price));
				}

				// 장바구 아이템의 총액을 계산후 표시.
				cartTotalPrice();
			});

			// 상품에 option의 버튼들을 클릭시.
			option.addEventListener('click', (event) => {
				// console.log(event.target);
				let element = event.target;
				let strClass = element.getAttribute('class');
				// console.log(element.getAttribute('class'));

				if (strClass.indexOf('goods_color') > -1) {
					// console.log('@ goods_color click !!');

					let gcArr = document.getElementsByClassName('goods_color');
					for (let i = 0; i < gcArr.length; i++) {
						const element = gcArr[i];
						element.setAttribute('class', 'btn btn-sm goods_color');
					}
					element.setAttribute('class', 'btn btn-sm goods_color font-weight-bold');
					data.option.goods_color = element.innerHTML;
				}

				if (strClass.indexOf('goods_size') > -1) {
					// console.log('@ goods_size click !!');

					let gsArr = document.getElementsByClassName('goods_size');
					for (let i = 0; i < gsArr.length; i++) {
						const element = gsArr[i];
						element.setAttribute('class', 'btn btn-sm goods_size');
					}
					element.setAttribute('class', 'btn btn-sm goods_size font-weight-bold');
					data.option.goods_size = element.innerHTML;
				}

				// console.log('>>', data);

				// ajax
				axios({
					  method: 'get',
					  url: '/board/option?goods_color='+data.option.goods_color+'&goods_size='+data.option.goods_size+'&goods_no='+data.option.goods_no,
						
					})
					  .then(function (response) {
					    console.log('response.data', response.data);
						let dto = response.data;
						console.log('data', dto);
					    if(dto) {

							let colors = dto.goods_colors;
							let sizes = dto.goods_sizes;
							let untpc = dto.goods_untpc;
							data.option.goods_untpc = untpc;
							
							let str = '';
										str +='<!-- 옵션 color  -->'
										str +='<div class="row">'
								for (let i = 0; i < colors.length; i++) {
									const item = colors[i];
									// console.log(dto.goods_color, data.goods_color);
									if (item.goods_color === dto.goods_color) {
										str +=	'<div class="col-md">'
										str +=		'<p class="btn btn-sm goods_color font-weight-bold">'+item.goods_color+'</p>'
										str +=	'</div>'
									} else {
										str +=	'<div class="col-md">'
										str +=		'<p class="btn btn-sm goods_color">'+item.goods_color+'</p>'
										str +=	'</div>'
									}
								}
										str +='</div>'
										str +='<!-- 옵션 size  -->'
										str +='<div class="row">'
								// console.log(sizes);
								for (let i = 0; i < sizes.length; i++) {
									const item = sizes[i];
									// console.log(dto.goods_size, data.goods_size);
									if (item.goods_size === dto.goods_size) {
										str +=	'<div class="col-md">'
										str +=		'<p class="btn btn-sm goods_size font-weight-bold">'+item.goods_size+'</p>'
										str +=	'</div>'
									} else {
										str +=	'<div class="col-md">'
										str +=		'<p class="btn btn-sm goods_size">'+item.goods_size+'</p>'
										str +=	'</div>'
									}
								}
										str +='</div>'
										str +='<!-- 옵션 color와 size에 따른 가격  -->'
										str +='<div class="row">'
										str +=	'<div class="col-md ml-2 mt-5">'
										str +=		'<h3><strong class="goods_untpc" id="untpc">'+dto.goods_untpc+'</strong>원</h3>'
										str +=	'</div>'
										str +='</div>';
							// console.log(str);
							option.innerHTML = str;

							document.getElementById('untpc').innerHTML = numberWithCommas(untpc);

							if(data.goods_amount > 0) {
								btnCollapse.setAttribute('disarbled', 'disarbled');
							} else {
								btnCollapse.removeAttribute('disarbled');
							}
						}
					  });
			});
		}); // DOMContentLoaded

		// 장바구 아이템의 총액을 계산후 표시.
		function cartTotalPrice() {
			let prices = list.getElementsByClassName('price');
				let sumPrice = 0;
				for (let i = 0; i < prices.length; i++) {
					const element = prices[i];
					let strPrice = element.innerHTML;
					let numPrice = strPrice.replace(',', '');
					if(Number(numPrice) !== NaN) {
						sumPrice += Number(numPrice);
					}
				}
				// let re = new RegExp('/\B(?=(\d{3})+(?!\d))/g');
				totalPrice.innerHTML = numberWithCommas(sumPrice);
		};

		// 자리수 표시(3자리 마다, 표시)
		function numberWithCommas(num) {
			let strNum = String(num).replace(/\B(?=(\d{3})+(?!\d))/g, ",");
			return strNum;
		};
	</script>
</head>

<body>
	<div class="clearfix text-secondary">
		<div class="collapse" id="collapseExample">
			<div class="text-right text-primary mr-2">
				<svg id="hide" width="1em" height="1em" viewBox="0 0 16 16" class="bi bi-x" fill="currentColor"
					xmlns="http://www.w3.org/2000/svg">
					<path fill-rule="evenodd"
						d="M11.854 4.146a.5.5 0 0 1 0 .708l-7 7a.5.5 0 0 1-.708-.708l7-7a.5.5 0 0 1 .708 0z" />
					<path fill-rule="evenodd"
						d="M4.146 4.146a.5.5 0 0 0 0 .708l7 7a.5.5 0 0 0 .708-.708l-7-7a.5.5 0 0 0-.708 0z" />
				</svg>
			</div>
			<div class="row ml-4 text-center">
				<div class="col-md-1">이미지</div>
				<div class="col-md-5">타이틀</div>
				<div class="col-md-1">사이즈</div>
				<div class="col-md-1">색상</div>
				<div class="col-md-2">수량</div>
				<div class="col-md-2">가격</div>
			</div>

			<div class="" id="list">

				<!-- <div class="row ml-4 mb-2 text-center">
					<div class="col-md-1"><img src="/displayfile?img_name=${dto.goods_img}" width="60px" height="60px"></div>
					<div class="col-md-5">이쁜이들은 어떤 마스크를 쓸까?</div>
					<div class="col-md-1">free</div>
					<div class="col-md-1">blue</div>
					<div class="col-md-2 line">
						<div class="row">
							<div class="col"><p class="btn minus">-</p></div>
							<div class="col mt-2"><p class="amount">1</p></div>
							<div class="col"><p class="btn plus text-muted">+</p></div>
						</div>
					</div>
					<div class="col-md-2 price" data-u-price="15900">15,900</div>
				</div> -->

			</div>
			
			<div class="row text-right">
				<div class="col-md mr-5">
					<h3 id="totalPrice">0</h3>
				</div>
			</div>
			<hr>
		</div>
	</div>

	<!--장바구니, 로그인 | 회원가입   -->
	<%@ include file="../com/top.jsp"%>
	<!--타이틀(홈 링크)   -->
	<%@ include file="../com/title.jsp"%>

	<div class="container">
		<%@ include file="../com/navbar.jsp"%>
		<img id="main" src="/displayfile?img_name=${dto.goods_info_img}" width="100%" />

		<h3 class="text-muted mt-4">${dto.goods_nm}</h3>

		<div class="row">
			<div class="col-md-8">
				<pre class="text-muted mt-4">${dto.goods_info_text }</pre>
			</div>
			<div class="col-md-4 mt-4 text-muted" id="option">
				<!-- 옵션 color  -->
				<div class="row">
					<c:forEach items="${dto.goods_colors }" var="option" varStatus="status">
						<c:if test="${status.index eq 0 }">
							<div class="col-md">
								<p class="btn btn-sm goods_color font-weight-bold">${option.goods_color }</p>
							</div>
						</c:if>
						<c:if test="${status.index ne 0 }">
							<div class="col-md">
								<p class="btn btn-sm goods_color">${option.goods_color }</p>
							</div>
						</c:if>
					</c:forEach>
				</div>

				<!-- 옵션 size  -->
				<div class="row">
					<c:forEach items="${dto.goods_sizes }" var="option" varStatus="status">
						<c:if test="${status.index eq 0 }">
							<div class="col-md">
								<p class="btn btn-sm goods_size font-weight-bold">${option.goods_size }</p>
							</div>
						</c:if>
						<c:if test="${status.index ne 0 }">
							<div class="col-md">
								<p class="btn btn-sm goods_size">${option.goods_size }</p>
							</div>
						</c:if>
					</c:forEach>
				</div>

				<!-- 옵션 color와 size에 따른 가격  -->
				<div class="row">
					<div class="col-md ml-2 mt-5">
						<h3><strong class="goods_untpc" id="untpc">${dto.goods_untpc }</strong>원</h3>
					</div>
				</div>

			</div>
		</div>
		<c:if test="${dto.goods_amount > 0 }">
			<button type="button" class="btn btn-outline-dark rounded-0 btn-lg btn-block mt-5 mb-5" id="btnCollapse" >구매</button>
		</c:if>
		<c:if test="${dto.goods_amount <= 0 }">
			<button type="button" class="btn btn-outline-dark rounded-0 btn-lg btn-block mt-5 mb-5" id="btnCollapse" disabled="disabled">재고없음</button>
		</c:if>
		
		<%@ include file="../com/footer.jsp"%>
	</div>
</body>

</html>