import "package:test/test.dart";

import "package:bech32/segwit.dart";
import "package:bech32/exceptions.dart";

void main() {
  group("segwit with", () {
    group("valid test vectors from specification", () {
      List<List<String>> valid = [
        [
          "BC1QW508D6QEJXTDG4Y5R3ZARVARY0C5XW7KV8F3T4",
          "0014751e76e8199196d454941c45d1b3a323f1433bd6"
        ],
        [
          "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sl5k7",
          "00201863143c14c5166804bd19203356da136c985678cd4d27a1b8c6329604903262"
        ],
        [
          "bc1pw508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7k7grplx",
          "5128751e76e8199196d454941c45d1b3a323f1433bd6751e76e8199196d454941c45d1b3a323f1433bd6"
        ],
        ["BC1SW50QA3JX3S", "6002751e"],
        [
          "bc1zw508d6qejxtdg4y5r3zarvaryvg6kdaj",
          "5210751e76e8199196d454941c45d1b3a323"
        ],
        [
          "tb1qqqqqp399et2xygdj5xreqhjjvcmzhxw4aywxecjdzew6hylgvsesrxh6hy",
          "0020000000c4a5cad46221b2a187905e5266362b99d5e91c6ce24d165dab93e86433"
        ],
      ];

      valid.forEach((tuple) {
        test("convert to correct scriptPubky: ${tuple[0]}", () {
          expect(segwit.decode(tuple[0]), tuple[1]);
        });
      });

      valid.forEach((tuple) {
        test("decode then encode static vector: $tuple", () {
          expect(
              segwit.encode(segwit.decode(tuple[0])), tuple[0].toLowerCase());
        });
      });
    });

    group("invalid test vectors from specification having", () {
      test("invalid hrp", () {
        expect(
            () => segwit.decode("tc1qw508d6qejxtdg4y5r3zarvary0c5xw7kg3g4ty"),
            throwsA(TypeMatcher<InvalidHrp>()));
      });

      test("invalid checksum", () {
        expect(
            () => segwit.decode("bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t5"),
            throwsA(TypeMatcher<InvalidChecksum>()));
      });

      test("invalid witness version", () {
        expect(
            () => segwit.decode("BC13W508D6QEJXTDG4Y5R3ZARVARY0C5XW7KN40WF2"),
            throwsA(TypeMatcher<InvalidWitnessVersion>()));
      });

      test("invalid program length (too short)", () {
        expect(() => segwit.decode("bc1rw5uspcuh"),
            throwsA(TypeMatcher<InvalidProgramLength>()));
      });

      test("invalid program length (too long)", () {
        expect(
            () => segwit.decode(
                "bc10w508d6qejxtdg4y5r3zarvary0c5xw7kw508d6qejxtdg4y5r3zarvary0c5xw7kw5rljs90"),
            throwsA(TypeMatcher<InvalidProgramLength>()));
      });

      test("invalid program length (for witness version 0)", () {
        expect(() => segwit.decode("BC1QR508D6QEJXTDG4Y5R3ZARVARYV98GJ9P"),
            throwsA(TypeMatcher<InvalidProgramLength>()));
      });

      test("mixed case", () {
        expect(
            () => segwit.decode(
                "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3q0sL5k7"),
            throwsA(TypeMatcher<MixedCase>()));
      });

      test("zero padding of more than 4 bytes", () {
        expect(() => segwit.decode("bc1zw508d6qejxtdg4y5r3zarvaryvqyzf3du"),
            throwsA(TypeMatcher<InvalidPadding>()));
      });

      test("non zero padding in 8-to-5 conversion", () {
        expect(
            () => segwit.decode(
                "tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3pjxtptv"),
            throwsA(TypeMatcher<InvalidPadding>()));
      });

      test("empty data", () {
        expect(() => segwit.decode("bc1gmk9yu"),
            throwsA(TypeMatcher<InvalidProgramLength>()));
      });
    });
  });
}
