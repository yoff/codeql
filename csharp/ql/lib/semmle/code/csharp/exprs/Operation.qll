/**
 * Provides classes for operations that also have compound assignment forms.
 */

import Expr

/** A binary operation that involves a null-coalescing operation. */
abstract private class NullCoalescingOperationImpl extends BinaryOperation { }

final class NullCoalescingOperation = NullCoalescingOperationImpl;

private class AddNullCoalescingExpr extends NullCoalescingOperationImpl instanceof NullCoalescingExpr
{ }

private class AddAssignCoalesceExpr extends NullCoalescingOperationImpl instanceof AssignCoalesceExpr
{ }

/** A binary operations that involves an addition operation. */
abstract private class AddOperationImpl extends BinaryOperation { }

final class AddOperation = AddOperationImpl;

private class AddAddExpr extends AddOperationImpl instanceof AddExpr { }

private class AddAssignExpr extends AddOperationImpl instanceof AssignAddExpr { }

/** A binary operation that involves a subtraction operation. */
abstract private class SubOperationImpl extends BinaryOperation { }

final class SubOperation = SubOperationImpl;

private class AddSubExpr extends SubOperationImpl instanceof SubExpr { }

private class AddSubAssignExpr extends SubOperationImpl instanceof AssignSubExpr { }

/** A binary operation that involves a multiplication operation. */
abstract private class MulOperationImpl extends BinaryOperation { }

final class MulOperation = MulOperationImpl;

private class AddMulExpr extends MulOperationImpl instanceof MulExpr { }

private class AddMulAssignExpr extends MulOperationImpl instanceof AssignMulExpr { }

/** A binary operation that involves a division operation. */
abstract private class DivOperationImpl extends BinaryOperation {
  /** Gets the denominator of this division operation. */
  Expr getDenominator() { result = this.getRightOperand() }
}

final class DivOperation = DivOperationImpl;

private class AddDivExpr extends DivOperationImpl instanceof DivExpr { }

private class AddDivAssignExpr extends DivOperationImpl instanceof AssignDivExpr { }

/** A binary operation that involves a remainder operation. */
abstract private class RemOperationImpl extends BinaryOperation { }

final class RemOperation = RemOperationImpl;

private class AddRemExpr extends RemOperationImpl instanceof RemExpr { }

private class AddRemAssignExpr extends RemOperationImpl instanceof AssignRemExpr { }

/** A binary operation that involves a bitwise AND operation. */
abstract private class BitwiseAndOperationImpl extends BinaryOperation { }

final class BitwiseAndOperation = BitwiseAndOperationImpl;

private class AddBitwiseAndExpr extends BitwiseAndOperationImpl instanceof BitwiseAndExpr { }

private class AddAssignBitwiseAndExpr extends BitwiseAndOperationImpl instanceof AssignAndExpr { }

/** A binary operation that involves a bitwise OR operation. */
abstract private class BitwiseOrOperationImpl extends BinaryOperation { }

final class BitwiseOrOperation = BitwiseOrOperationImpl;

private class AddBitwiseOrExpr extends BitwiseOrOperationImpl instanceof BitwiseOrExpr { }

private class AddAssignBitwiseOrExpr extends BitwiseOrOperationImpl instanceof AssignOrExpr { }

/** A binary operation that involves a bitwise XOR operation. */
abstract private class BitwiseXorOperationImpl extends BinaryOperation { }

final class BitwiseXorOperation = BitwiseXorOperationImpl;

private class AddBitwiseXorExpr extends BitwiseXorOperationImpl instanceof BitwiseXorExpr { }

private class AddAssignBitwiseXorExpr extends BitwiseXorOperationImpl instanceof AssignXorExpr { }

/** A binary operation that involves a left shift operation. */
abstract private class LeftShiftOperationImpl extends BinaryOperation { }

final class LeftShiftOperation = LeftShiftOperationImpl;

private class AddLeftShiftExpr extends LeftShiftOperationImpl instanceof LeftShiftExpr { }

private class AddAssignLeftShiftExpr extends LeftShiftOperationImpl instanceof AssignLeftShiftExpr {
}

/** A binary operation that involves a right shift operation. */
abstract private class RightShiftOperationImpl extends BinaryOperation { }

final class RightShiftOperation = RightShiftOperationImpl;

private class AddRightShiftExpr extends RightShiftOperationImpl instanceof RightShiftExpr { }

private class AddAssignRightShiftExpr extends RightShiftOperationImpl instanceof AssignRightShiftExpr
{ }

/** A binary operation that involves a unsigned right shift operation. */
abstract private class UnsignedRightShiftOperationImpl extends BinaryOperation { }

final class UnsignedRightShiftOperation = UnsignedRightShiftOperationImpl;

private class AddUnsignedRightShiftExpr extends UnsignedRightShiftOperationImpl instanceof UnsignedRightShiftExpr
{ }

private class AddAssignUnsignedRightShiftExpr extends UnsignedRightShiftOperationImpl instanceof AssignUnsignedRightShiftExpr
{ }
