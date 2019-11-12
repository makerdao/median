pragma solidity >=0.5.10;

import "ds-test/test.sol";

import "./median.sol";

contract UnauthorizedPeek {
    Median m;
    constructor(Median m_) public {
        m = m_;
    }
    function doPeek() public view returns (uint256,bool) {
        return m.peek();
    }
    function doRead() public view returns (uint256) {
        return m.read();
    }
}

contract MedianTest is DSTest {
    Median m;
    UnauthorizedPeek u;

    function setUp() public {
        m = new Median();
        u = new UnauthorizedPeek(m);
    }

    function test_slot() public {
        address[] memory a = new address[](1);
	a[0] = address(0x0a00000000000000000000000000000000000000);
	address[] memory b = new address[](1);
	b[0] = address(0x0B00000000000000000000000000000000000000);
        m.lift(a);
        m.lift(b);
        m.drop(a);
        m.lift(a);
    }

    function testFail_slot() public {
        address[] memory a = new address[](1);
	a[0] = address(0x0a00000000000000000000000000000000000000);
        address[] memory b = new address[](1);
	b[0] = address(0x0A11111111111111111111111111111111111111);
        m.lift(a);
        m.lift(b);
    }

    function test_Median() public {

        //address payable [15] memory orcl = [
        //    0x2d6691a7Ca09FcFC8a069953AD4Ba4De11DbFFd6,
        //    0xEF7a293Adaec73c5E134040DDAd13a15CEB7231A,
        //    0xEd1fBB08C70D1d510cF6C6a8B31f69917F0eCd46,
        //    0xd4D2CBda7CA421A68aFdb72f16Ad38b8f0Ea3199,
        //    0x94e71Afc1C876762aF8aaEd569596E6Fe2d42d86,
        //    0x1379F663AE24cFD7cDaad6d8E0fa0dBf2F7D51fb,
        //    0x2a4B7b59323B8bC4a78d04a88E853469ED6ea1d4,
        //    0x8797FDdF08612100a8B821CD52f8B71dB75Fa9aC,
        //    0xdB3E64F17f5E6Af7161dCd01401464835136Af6C,
        //    0xCD63177834dDD54aDdD2d9F9845042A21360023A,
        //    0x832A0149Beea1e4cb7175b3062Edd10E1b40A951,
        //    0xb158f2EC0E44c7cE533C5e41ca5FB09575f1e210,
        //    0x555faE91fb4b03473704045737b8b5F628E9E5E5,
        //    0x8b8668B708D4edee400Dfd00e9A9038781eb5904,
        //    0x06B80b4034FEc8566857f0B9180b025e933093e4
        //];

	address[] memory orcl = new address[](15);
	orcl[0] = address(0x2d6691a7Ca09FcFC8a069953AD4Ba4De11DbFFd6);
	orcl[1] = address(0xEF7a293Adaec73c5E134040DDAd13a15CEB7231A);
	orcl[2] = address(0xEd1fBB08C70D1d510cF6C6a8B31f69917F0eCd46);
	orcl[3] = address(0xd4D2CBda7CA421A68aFdb72f16Ad38b8f0Ea3199);
	orcl[4] = address(0x94e71Afc1C876762aF8aaEd569596E6Fe2d42d86);
	orcl[5] = address(0x1379F663AE24cFD7cDaad6d8E0fa0dBf2F7D51fb);
	orcl[6] = address(0x2a4B7b59323B8bC4a78d04a88E853469ED6ea1d4);
	orcl[7] = address(0x8797FDdF08612100a8B821CD52f8B71dB75Fa9aC);
	orcl[8] = address(0xdB3E64F17f5E6Af7161dCd01401464835136Af6C);
	orcl[9] = address(0xCD63177834dDD54aDdD2d9F9845042A21360023A);
	orcl[10] = address(0x832A0149Beea1e4cb7175b3062Edd10E1b40A951);
	orcl[11] = address(0xb158f2EC0E44c7cE533C5e41ca5FB09575f1e210);
	orcl[12] = address(0x555faE91fb4b03473704045737b8b5F628E9E5E5);
	orcl[13] = address(0x8b8668B708D4edee400Dfd00e9A9038781eb5904);
	orcl[14] = address(0x06B80b4034FEc8566857f0B9180b025e933093e4);

        uint256[] memory price = new uint256[](15);

        price[0] = uint256(0x00000000000000000000000000000000000000000000000da04773c0e7dc8000);
        price[1] = uint256(0x00000000000000000000000000000000000000000000000dadaf5fa2ace38000);
        price[2] = uint256(0x00000000000000000000000000000000000000000000000dc37cafcfdb070000);
        price[3] = uint256(0x00000000000000000000000000000000000000000000000dd2cb5477ce488000);
        price[4] = uint256(0x00000000000000000000000000000000000000000000000dda50e698aa8b8000);
        price[5] = uint256(0x00000000000000000000000000000000000000000000000dee1b120a84408000);
        price[6] = uint256(0x00000000000000000000000000000000000000000000000df1f6b99173cf8000);
        price[7] = uint256(0x00000000000000000000000000000000000000000000000e05e46bf5bd458000);
        price[8] = uint256(0x00000000000000000000000000000000000000000000000e0d89f78a64830000);
        price[9] = uint256(0x00000000000000000000000000000000000000000000000e25afb05259b10000);
        price[10] = uint256(0x00000000000000000000000000000000000000000000000e2f0a37c02c4e0000);
        price[11] = uint256(0x00000000000000000000000000000000000000000000000e39eb8b98cc360000);
        price[12] = uint256(0x00000000000000000000000000000000000000000000000e4cab42f05fc38000);
        price[13] = uint256(0x00000000000000000000000000000000000000000000000e549b69e88b498000);
        price[14] = uint256(0x00000000000000000000000000000000000000000000000e68f023a57f3c0000);

        uint256[] memory ts = new uint256[](15);

        ts[0] = uint256(0x000000000000000000000000000000000000000000000000000000005c4a3710);
        ts[1] = uint256(0x000000000000000000000000000000000000000000000000000000005c4a3711);
        ts[2] = uint256(0x000000000000000000000000000000000000000000000000000000005c4a3712);
        ts[3] = uint256(0x000000000000000000000000000000000000000000000000000000005c4a3713);
        ts[4] = uint256(0x000000000000000000000000000000000000000000000000000000005c4a3714);
        ts[5] = uint256(0x000000000000000000000000000000000000000000000000000000005c4a3715);
        ts[6] = uint256(0x000000000000000000000000000000000000000000000000000000005c4a3716);
        ts[7] = uint256(0x000000000000000000000000000000000000000000000000000000005c4a3717);
        ts[8] = uint256(0x000000000000000000000000000000000000000000000000000000005c4a3719);
        ts[9] = uint256(0x000000000000000000000000000000000000000000000000000000005c4a371a);
        ts[10] = uint256(0x000000000000000000000000000000000000000000000000000000005c4a371b);
        ts[11] = uint256(0x000000000000000000000000000000000000000000000000000000005c4a371c);
        ts[12] = uint256(0x000000000000000000000000000000000000000000000000000000005c4a371d);
        ts[13] = uint256(0x000000000000000000000000000000000000000000000000000000005c4a371e);
        ts[14] = uint256(0x000000000000000000000000000000000000000000000000000000005c4a371f);

        uint8[] memory v = new uint8[](15);
        v[0] = uint8(0x1c);
        v[1] = uint8(0x1b);
        v[2] = uint8(0x1c);
        v[3] = uint8(0x1b);
        v[4] = uint8(0x1b);
        v[5] = uint8(0x1b);
        v[6] = uint8(0x1c);
        v[7] = uint8(0x1c);
        v[8] = uint8(0x1b);
        v[9] = uint8(0x1c);
        v[10] = uint8(0x1b);
        v[11] = uint8(0x1b);
        v[12] = uint8(0x1c);
        v[13] = uint8(0x1c);
        v[14] = uint8(0x1b);

        bytes32[] memory r = new bytes32[](15);

        r[0] = bytes32(0xcde732167a15601b67d9a5a03c14739f05a4128966d5e14157a97178c2b66268);
        r[1] = bytes32(0x5f7533150ce566f568f0157a9bcb119e84bc0fcee585a8e8fff14b10b7e87ce9);
        r[2] = bytes32(0xa5e83de72de8cd96edc991b774dbef19dfec5905a3b0438c8b4b14d799c234fb);
        r[3] = bytes32(0x9a13768dad10e3b2d22e37c5ba74b5fa5d71569efeaa45f8333fdcc799826861);
        r[4] = bytes32(0x18f7edbf9fa29b6965cd2b63f4a771847af0a1f5e29c0542d14659c3d22d9f39);
        r[5] = bytes32(0xa9f717be8c0f61aa4a9313858ef46defe4080e81565abe6f3c7b691be81b7512);
        r[6] = bytes32(0x1d4ddab4935b842e58a4f68813508693c968345d965f0ea65e2cb66d2d87278b);
        r[7] = bytes32(0xdb29ff83b98180bffb0a369972efa7f75a377621f4be9abd98bac8497b6cc7d7);
        r[8] = bytes32(0xbfe4434091e228a0d57a67ae1cec2d1f24eb470acbc99d3e44477e5ba86ec192);
        r[9] = bytes32(0xbfe9e874ce4b86886167310e252cb3e792f7577c78c6317131b3b23bd2bac23a);
        r[10] = bytes32(0x494a00afbf51e94a00fb802464a329788b1787cca413e9606e48b0d4c5db186a);
        r[11] = bytes32(0xd48a4227257fe62489dd5a876213f0c73dd28b5bbd0062b97c97ad359341a6d0);
        r[12] = bytes32(0x1036209fd741421b13c947b723c6c36723337831f261261a9f972c92c1024e9c);
        r[13] = bytes32(0xddbf5d9d124da617f20aabeadce531bc7bf5a5cc87eee996cd7a7acff335e659);
        r[14] = bytes32(0x46ad81c37b4fd40b16c428accb368bba91312a5b4491a747abb31594faaa30df);

        bytes32[] memory s = new bytes32[](15);

        s[0] = bytes32(0x7db1ca5ef537cd229d35c88395393f23c8f2bb4708d65d66bb625879686e87b5);
        s[1] = bytes32(0x6c2ee3a98dfeca39f1b9b79ddcb446be70e771e0737c296c537bfb01ed9f5eb4);
        s[2] = bytes32(0x1c29866da2db9480c8a7f2a691c194e3deb1c69b50c68005c1f70f20845ae127);
        s[3] = bytes32(0x7f6aa4bc4be9b59e95653563e6e82c44b26543a7e7f76e4ca5981d3a061f0c06);
        s[4] = bytes32(0x34fa2d01cd9d6d90376754d63f064079b8369c301545a55d47b1d281ddbe6c0e);
        s[5] = bytes32(0x7f414a67c20e574065134c43562956ae0c5831540b2a11d27f0cbf55c1a17838);
        s[6] = bytes32(0x54923524bf791d2e53955ca9016ac24f26c509a28a3bd297a4e2bf92be5c143a);
        s[7] = bytes32(0x4d81a95311ed8d44ec77725aaa9d7e376156de27a1400c61858e47945102df0a);
        s[8] = bytes32(0x304b355b420a75f432002c527ea1d1d073bbbe9383e8cc0b35a73e6ab4f8e643);
        s[9] = bytes32(0x6b115625e7b015434b85d5d3c2a0627564b78df43a12b8ea6f5fc778395fafde);
        s[10] = bytes32(0x036ff783f19deb152c42ec06238d9cb9de8697765103b32936d6d2cb441fada8);
        s[11] = bytes32(0x525cd8d3baf77dad049c7092cbbef6979e36924b88cc90faf09256c24552cf9d);
        s[12] = bytes32(0x242043c823bf48009cbf79e6114de1ce57fd2a031190966d00b89a16871534ed);
        s[13] = bytes32(0x69dd6213ef7c960ce7123a50dabd2a45d477c8ae3eca2bb860ec75902a23ca81);
        s[14] = bytes32(0x6573f1f517c89503a1116377f7ac80cbfe2b24bbc5dc1147d03da725198f8cc5);

        m.setBar(15);

	m.lift(orcl);

	address[] memory f = new address[](2);
	f[0] = address(this);
	f[1] = address(u);
        m.kiss(f);

        uint256 gas = gasleft();
        m.poke(price, ts, v, r, s);
        gas = gas - gasleft();
        emit log_named_uint("gas", gas);
        (uint256 val, bool ok) = m.peek();

        emit log_named_decimal_uint("median", val, 18);

        (val, ok) = u.doPeek();

        assertTrue(ok);
    }

}
