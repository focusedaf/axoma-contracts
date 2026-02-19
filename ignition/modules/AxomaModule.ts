import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("AxomaModule", (m) => {
  const issuerRegistry = m.contract("IssuerRegistry");

  const examRegistry = m.contract("ExamRegistry", [issuerRegistry]);

  const resultRegistry = m.contract("ResultRegistry", [examRegistry]);

  return {
    issuerRegistry,
    examRegistry,
    resultRegistry,
  };
});
