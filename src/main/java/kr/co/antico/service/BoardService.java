package kr.co.antico.service;

import java.util.List;

import kr.co.domain.GoodsDTO;
import kr.co.domain.GoodsOptionDTO;

public interface BoardService {

	List<GoodsDTO> list();

	List<GoodsOptionDTO> option();

	



}
