/*
 ***********************************************************************************************************************
 *
 *  Copyright (c) 2019-2020 Advanced Micro Devices, Inc. All Rights Reserved.
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
 *
 **********************************************************************************************************************/
/**
 ***********************************************************************************************************************
 * @file  llpcBuilderImplMatrix.cpp
 * @brief LLPC source file: implementation of matrix Builder methods
 ***********************************************************************************************************************
 */
#include "llpcBuilderImpl.h"

#define DEBUG_TYPE "llpc-builder-impl-matrix"

using namespace lgc;
using namespace llvm;

// =====================================================================================================================
// Create a matrix transpose.
Value* BuilderImplMatrix::CreateTransposeMatrix(
    Value* const matrix,  // [in] Matrix to transpose.
    const Twine& instName) // [in] Name to give final instruction
{
    assert(matrix != nullptr);

    Type* const matrixType = matrix->getType();
    assert(matrixType->isArrayTy());

    Type* const columnVectorType = matrixType->getArrayElementType();
    assert(columnVectorType->isVectorTy());

    const unsigned columnCount = matrixType->getArrayNumElements();
    const unsigned rowCount = columnVectorType->getVectorNumElements();

    Type* const elementType = columnVectorType->getVectorElementType();

    Type* const newColumnVectorType = VectorType::get(elementType, columnCount);
    Type* const newMatrixType = ArrayType::get(newColumnVectorType, rowCount);

    SmallVector<Value*, 4> columns;

    for (unsigned column = 0; column < columnCount; column++)
        columns.push_back(CreateExtractValue(matrix, column));

    SmallVector<Value*, 4> newColumns;

    for (unsigned row = 0; row < rowCount; row++)
        newColumns.push_back(UndefValue::get(newColumnVectorType));

    for (unsigned column = 0; column < columnCount; column++)
    {
        for (unsigned row = 0; row < rowCount; row++)
        {
            Value* const element = CreateExtractElement(columns[column], row);
            newColumns[row] = CreateInsertElement(newColumns[row], element, column);
        }
    }

    Value* newMatrix = UndefValue::get(newMatrixType);

    for (unsigned row = 0; row < rowCount; row++)
        newMatrix = CreateInsertValue(newMatrix, newColumns[row], row);

    newMatrix->setName(instName);
    return newMatrix;
}

// =====================================================================================================================
// Create matrix from matrix Times scalar
Value* BuilderImplMatrix::CreateMatrixTimesScalar(
    Value* const matrix,             // [in] The column major matrix, n x <n x float>
    Value* const scalar,             // [in] The float scalar
    const Twine& instName)            // [in] Name to give instruction(s)
{
    Type* const matrixTy = matrix->getType();
    Type* const columnTy = matrixTy->getArrayElementType();
    const unsigned rowCount = columnTy->getVectorNumElements();
    unsigned columnCount = matrixTy->getArrayNumElements();
    auto smearScalar = CreateVectorSplat(rowCount, scalar);

    Value* result = UndefValue::get(matrixTy);
    for (unsigned column = 0; column < columnCount; column++)
    {
        auto columnVector = CreateExtractValue(matrix, column);
        columnVector = CreateFMul(columnVector, smearScalar);
        result = CreateInsertValue(result, columnVector, column);
    }

    result->setName(instName);
    return result;
}

// =====================================================================================================================
// Create vector from vector Times matrix
Value* BuilderImplMatrix::CreateVectorTimesMatrix(
    Value* const vector,         // [in] The float vector
    Value* const matrix,         // [in] The column major matrix, n x <n x float>
    const Twine& instName)        // [in] Name to give instruction(s)
{
    Type* const matrixTy = matrix->getType();
    Type* const compTy = matrixTy->getArrayElementType()->getVectorElementType();
    const unsigned columnCount = matrixTy->getArrayNumElements();
    Type* const resultTy = VectorType::get(compTy, columnCount);
    Value* result = UndefValue::get(resultTy);

    for (unsigned column = 0; column < columnCount; column++)
    {
        auto columnVector = CreateExtractValue(matrix, column);
        result = CreateInsertElement(result, CreateDotProduct(columnVector, vector), column);
    }

    result->setName(instName);
    return result;
}

// =====================================================================================================================
// Create vector from matrix times vector
Value* BuilderImplMatrix::CreateMatrixTimesVector(
    Value* const matrix,             // [in] The column major matrix, n x <n x float>
    Value* const vector,             // [in] The vector
    const Twine& instName)            // [in] Name to give instruction(s)
{
    Type* const columnTy = matrix->getType()->getArrayElementType();
    const unsigned rowCount = columnTy->getVectorNumElements();
    Value* result = nullptr;

    for (unsigned i = 0; i < matrix->getType()->getArrayNumElements(); ++i)
    {
        SmallVector<unsigned, 4> shuffleMask(rowCount, i);
        auto partialResult = CreateShuffleVector(vector, vector, shuffleMask);
        partialResult = CreateFMul(CreateExtractValue(matrix, i), partialResult);
        if (result != nullptr)
            result = CreateFAdd(result, partialResult);
        else
            result = partialResult;
    }

    result->setName(instName);
    return result;
}

// =====================================================================================================================
// Create matrix from matrix times matrix
Value* BuilderImplMatrix::CreateMatrixTimesMatrix(
    Value* const matrix1,             // [in] The float matrix 1
    Value* const matrix2,             // [in] The float matrix 2
    const Twine& instName)             // [in] Name to give instruction(s)
{
    Type* const mat1ColumnType = matrix1->getType()->getArrayElementType();
    const unsigned mat2ColCount = matrix2->getType()->getArrayNumElements();
    Type* const resultTy = ArrayType::get(mat1ColumnType, mat2ColCount);
    Value* result = UndefValue::get(resultTy);

    for (unsigned i = 0; i < mat2ColCount; ++i)
    {
        Value* newColumnVector = CreateMatrixTimesVector(matrix1, CreateExtractValue(matrix2, i));
        result = CreateInsertValue(result, newColumnVector, i);
    }

    result->setName(instName);
    return result;
}

// =====================================================================================================================
// Create matrix from outer product of vector
Value* BuilderImplMatrix::CreateOuterProduct(
    Value* const vector1,            // [in] The float vector 1
    Value* const vector2,            // [in] The float vector 2
    const Twine& instName)            // [in] Name to give instruction(s)
{
    const unsigned rowCount = vector1->getType()->getVectorNumElements();
    const unsigned colCount = vector2->getType()->getVectorNumElements();
    Type* const resultTy = ArrayType::get(vector1->getType(), colCount);
    Value* result = UndefValue::get(resultTy);

    for (unsigned i = 0; i < colCount; ++i)
    {
        SmallVector<unsigned, 4> shuffleIdx(rowCount, i);
        Value* columnVector = CreateFMul(vector1, CreateShuffleVector(vector2, vector2, shuffleIdx));
        result = CreateInsertValue(result, columnVector, i);
    }

    result->setName(instName);
    return result;
}

// =====================================================================================================================
// Create matrix determinant operation. Matrix must be square
Value* BuilderImplMatrix::CreateDeterminant(
    Value* const matrix,     // [in] Matrix
    const Twine& instName)    // [in] Name to give instruction(s)
{
    unsigned order = matrix->getType()->getArrayNumElements();
    assert(matrix->getType()->getArrayElementType()->getVectorNumElements() == order);
    assert(order >= 2);

    // Extract matrix elements.
    SmallVector<Value*, 16> elements;
    for (unsigned columnIdx = 0; columnIdx != order; ++columnIdx)
    {
        Value* column = CreateExtractValue(matrix, columnIdx);
        for (unsigned rowIdx = 0; rowIdx != order; ++rowIdx)
            elements.push_back(CreateExtractElement(column, rowIdx));
    }

    Value* result = determinant(elements, order);
    result->setName(instName);
    return result;
}

// =====================================================================================================================
// Helper function for determinant calculation
Value* BuilderImplMatrix::determinant(
    ArrayRef<Value*>    elements,     // Elements of matrix (order*order of them)
    unsigned            order)        // Order of matrix
{
    if (order == 1)
        return elements[0];

    if (order == 2)
    {
        // | x0   x1 |
        // |         | = x0 * y1 - y0 * x1
        // | y0   y1 |
        return CreateFSub(CreateFMul(elements[0], elements[3]), CreateFMul(elements[1], elements[2]));
    }

    // | x0   x1   x2 |
    // |              |        | y1 y2 |        | x1 x2 |        | x1 x2 |
    // | y0   y1   y2 | = x0 * |       | - y0 * |       | + z0 * |       |
    // |              |        | z1 z2 |        | z1 z2 |        | y1 y2 |
    // | z0   z1   z2 |
    SmallVector<Value*, 9> submatrix;
    submatrix.resize((order - 1) * (order - 1));
    Value* result = nullptr;
    for (unsigned leadRowIdx = 0; leadRowIdx != order; ++leadRowIdx)
    {
        getSubmatrix(elements, submatrix, order, leadRowIdx, 0);
        Value* subdeterminant = CreateFMul(elements[leadRowIdx], determinant(submatrix, order - 1));
        if ((leadRowIdx & 1) != 0)
            result = CreateFSub(result, subdeterminant);
        else
        {
            if (result == nullptr)
                result = subdeterminant;
            else
                result = CreateFAdd(result, subdeterminant);
        }
    }
    return result;
}

// =====================================================================================================================
// Get submatrix by deleting specified row and column
void BuilderImplMatrix::getSubmatrix(
    ArrayRef<Value*>        matrix,         // Input matrix (as linearized array of values, order*order of them)
    MutableArrayRef<Value*> submatrix,      // Output matrix (ditto, (order-1)*(order-1) of them)
    unsigned                order,          // Order of input matrix
    unsigned                rowToDelete,    // Row index to delete
    unsigned                columnToDelete) // Column index to delete
{
    unsigned inElementIdx = 0, outElementIdx = 0;
    for (unsigned columnIdx = 0; columnIdx != order; ++columnIdx)
    {
        for (unsigned rowIdx = 0; rowIdx != order; ++rowIdx)
        {
            if ((rowIdx != rowToDelete) && (columnIdx != columnToDelete))
                submatrix[outElementIdx++] = matrix[inElementIdx];
            ++inElementIdx;
        }
    }
}

// =====================================================================================================================
// Create matrix inverse operation. Matrix must be square. Result is undefined if the matrix
// is singular or poorly conditioned (nearly singular).
Value* BuilderImplMatrix::CreateMatrixInverse(
    Value* const matrix,     // [in] Matrix
    const Twine& instName)    // [in] Name to give instruction(s)
{
    unsigned order = matrix->getType()->getArrayNumElements();
    assert(matrix->getType()->getArrayElementType()->getVectorNumElements() == order);
    assert(order >= 2);

    // Extract matrix elements.
    SmallVector<Value*, 16> elements;
    for (unsigned columnIdx = 0; columnIdx != order; ++columnIdx)
    {
        Value* column = CreateExtractValue(matrix, columnIdx);
        for (unsigned rowIdx = 0; rowIdx != order; ++rowIdx)
            elements.push_back(CreateExtractElement(column, rowIdx));
    }

    // [ x0   x1   x2 ]                   [ Adj(x0) Adj(x1) Adj(x2) ] T
    // [              ]                   [                         ]
    // [ y0   y1   y2 ]  = (1 / det(M)) * [ Adj(y0) Adj(y1) Adj(y2) ]
    // [              ]                   [                         ]
    // [ z0   z1   z2 ]                   [ Adj(z0) Adj(z1) Adj(z2) ]
    //
    // where Adj(a) is the cofactor of a, which is the determinant of the submatrix obtained by deleting
    // the row and column of a, then negated if row+col is odd.

    SmallVector<Value*, 16> resultElements;
    resultElements.resize(order * order);
    SmallVector<Value*, 9> submatrix;
    submatrix.resize((order - 1) * (order - 1));

    // Calculate reciprocal of determinant, and negated reciprocal of determinant.
    Value* rcpDet = CreateFDiv(ConstantFP::get(elements[0]->getType(), 1.0), determinant(elements, order));
    Value* negRcpDet = CreateFSub(Constant::getNullValue(elements[0]->getType()), rcpDet);

    // For each element:
    for (unsigned columnIdx = 0; columnIdx != order; ++columnIdx)
    {
        for (unsigned rowIdx = 0; rowIdx != order; ++rowIdx)
        {
            // Calculate cofactor for this element.
            getSubmatrix(elements, submatrix, order, rowIdx, columnIdx);
            // Calculate its determinant.
            Value* cofactor = determinant(submatrix, order - 1);
            // Divide by whole matrix determinant, and negate if row+col is odd.
            cofactor = CreateFMul(cofactor,
                                   (((rowIdx + columnIdx) & 1) != 0) ? negRcpDet : rcpDet);
            // Transpose by placing the cofactor in the transpose position.
            resultElements[rowIdx * order + columnIdx] = cofactor;
        }
    }

    // Create the result matrix.
    Value* result = UndefValue::get(matrix->getType());
    for (unsigned columnIdx = 0; columnIdx != order; ++columnIdx)
    {
        Value* column = UndefValue::get(matrix->getType()->getArrayElementType());
        for (unsigned rowIdx = 0; rowIdx != order; ++rowIdx)
            column = CreateInsertElement(column, resultElements[rowIdx + columnIdx * order], rowIdx);
        result = CreateInsertValue(result, column, columnIdx);
    }

    result->setName(instName);
    return result;
}

