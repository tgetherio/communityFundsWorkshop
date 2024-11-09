// Code generated by mockery v2.43.2. DO NOT EDIT.

package mocks

import (
	context "context"

	mock "github.com/stretchr/testify/mock"

	types "github.com/smartcontractkit/chainlink/v2/common/types"
)

// KeyStore is an autogenerated mock type for the KeyStore type
type KeyStore[ADDR types.Hashable, CHAIN_ID types.ID, SEQ types.Sequence] struct {
	mock.Mock
}

type KeyStore_Expecter[ADDR types.Hashable, CHAIN_ID types.ID, SEQ types.Sequence] struct {
	mock *mock.Mock
}

func (_m *KeyStore[ADDR, CHAIN_ID, SEQ]) EXPECT() *KeyStore_Expecter[ADDR, CHAIN_ID, SEQ] {
	return &KeyStore_Expecter[ADDR, CHAIN_ID, SEQ]{mock: &_m.Mock}
}

// CheckEnabled provides a mock function with given fields: ctx, address, chainID
func (_m *KeyStore[ADDR, CHAIN_ID, SEQ]) CheckEnabled(ctx context.Context, address ADDR, chainID CHAIN_ID) error {
	ret := _m.Called(ctx, address, chainID)

	if len(ret) == 0 {
		panic("no return value specified for CheckEnabled")
	}

	var r0 error
	if rf, ok := ret.Get(0).(func(context.Context, ADDR, CHAIN_ID) error); ok {
		r0 = rf(ctx, address, chainID)
	} else {
		r0 = ret.Error(0)
	}

	return r0
}

// KeyStore_CheckEnabled_Call is a *mock.Call that shadows Run/Return methods with type explicit version for method 'CheckEnabled'
type KeyStore_CheckEnabled_Call[ADDR types.Hashable, CHAIN_ID types.ID, SEQ types.Sequence] struct {
	*mock.Call
}

// CheckEnabled is a helper method to define mock.On call
//   - ctx context.Context
//   - address ADDR
//   - chainID CHAIN_ID
func (_e *KeyStore_Expecter[ADDR, CHAIN_ID, SEQ]) CheckEnabled(ctx interface{}, address interface{}, chainID interface{}) *KeyStore_CheckEnabled_Call[ADDR, CHAIN_ID, SEQ] {
	return &KeyStore_CheckEnabled_Call[ADDR, CHAIN_ID, SEQ]{Call: _e.mock.On("CheckEnabled", ctx, address, chainID)}
}

func (_c *KeyStore_CheckEnabled_Call[ADDR, CHAIN_ID, SEQ]) Run(run func(ctx context.Context, address ADDR, chainID CHAIN_ID)) *KeyStore_CheckEnabled_Call[ADDR, CHAIN_ID, SEQ] {
	_c.Call.Run(func(args mock.Arguments) {
		run(args[0].(context.Context), args[1].(ADDR), args[2].(CHAIN_ID))
	})
	return _c
}

func (_c *KeyStore_CheckEnabled_Call[ADDR, CHAIN_ID, SEQ]) Return(_a0 error) *KeyStore_CheckEnabled_Call[ADDR, CHAIN_ID, SEQ] {
	_c.Call.Return(_a0)
	return _c
}

func (_c *KeyStore_CheckEnabled_Call[ADDR, CHAIN_ID, SEQ]) RunAndReturn(run func(context.Context, ADDR, CHAIN_ID) error) *KeyStore_CheckEnabled_Call[ADDR, CHAIN_ID, SEQ] {
	_c.Call.Return(run)
	return _c
}

// EnabledAddressesForChain provides a mock function with given fields: ctx, chainId
func (_m *KeyStore[ADDR, CHAIN_ID, SEQ]) EnabledAddressesForChain(ctx context.Context, chainId CHAIN_ID) ([]ADDR, error) {
	ret := _m.Called(ctx, chainId)

	if len(ret) == 0 {
		panic("no return value specified for EnabledAddressesForChain")
	}

	var r0 []ADDR
	var r1 error
	if rf, ok := ret.Get(0).(func(context.Context, CHAIN_ID) ([]ADDR, error)); ok {
		return rf(ctx, chainId)
	}
	if rf, ok := ret.Get(0).(func(context.Context, CHAIN_ID) []ADDR); ok {
		r0 = rf(ctx, chainId)
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).([]ADDR)
		}
	}

	if rf, ok := ret.Get(1).(func(context.Context, CHAIN_ID) error); ok {
		r1 = rf(ctx, chainId)
	} else {
		r1 = ret.Error(1)
	}

	return r0, r1
}

// KeyStore_EnabledAddressesForChain_Call is a *mock.Call that shadows Run/Return methods with type explicit version for method 'EnabledAddressesForChain'
type KeyStore_EnabledAddressesForChain_Call[ADDR types.Hashable, CHAIN_ID types.ID, SEQ types.Sequence] struct {
	*mock.Call
}

// EnabledAddressesForChain is a helper method to define mock.On call
//   - ctx context.Context
//   - chainId CHAIN_ID
func (_e *KeyStore_Expecter[ADDR, CHAIN_ID, SEQ]) EnabledAddressesForChain(ctx interface{}, chainId interface{}) *KeyStore_EnabledAddressesForChain_Call[ADDR, CHAIN_ID, SEQ] {
	return &KeyStore_EnabledAddressesForChain_Call[ADDR, CHAIN_ID, SEQ]{Call: _e.mock.On("EnabledAddressesForChain", ctx, chainId)}
}

func (_c *KeyStore_EnabledAddressesForChain_Call[ADDR, CHAIN_ID, SEQ]) Run(run func(ctx context.Context, chainId CHAIN_ID)) *KeyStore_EnabledAddressesForChain_Call[ADDR, CHAIN_ID, SEQ] {
	_c.Call.Run(func(args mock.Arguments) {
		run(args[0].(context.Context), args[1].(CHAIN_ID))
	})
	return _c
}

func (_c *KeyStore_EnabledAddressesForChain_Call[ADDR, CHAIN_ID, SEQ]) Return(_a0 []ADDR, _a1 error) *KeyStore_EnabledAddressesForChain_Call[ADDR, CHAIN_ID, SEQ] {
	_c.Call.Return(_a0, _a1)
	return _c
}

func (_c *KeyStore_EnabledAddressesForChain_Call[ADDR, CHAIN_ID, SEQ]) RunAndReturn(run func(context.Context, CHAIN_ID) ([]ADDR, error)) *KeyStore_EnabledAddressesForChain_Call[ADDR, CHAIN_ID, SEQ] {
	_c.Call.Return(run)
	return _c
}

// SubscribeToKeyChanges provides a mock function with given fields: ctx
func (_m *KeyStore[ADDR, CHAIN_ID, SEQ]) SubscribeToKeyChanges(ctx context.Context) (chan struct{}, func()) {
	ret := _m.Called(ctx)

	if len(ret) == 0 {
		panic("no return value specified for SubscribeToKeyChanges")
	}

	var r0 chan struct{}
	var r1 func()
	if rf, ok := ret.Get(0).(func(context.Context) (chan struct{}, func())); ok {
		return rf(ctx)
	}
	if rf, ok := ret.Get(0).(func(context.Context) chan struct{}); ok {
		r0 = rf(ctx)
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(chan struct{})
		}
	}

	if rf, ok := ret.Get(1).(func(context.Context) func()); ok {
		r1 = rf(ctx)
	} else {
		if ret.Get(1) != nil {
			r1 = ret.Get(1).(func())
		}
	}

	return r0, r1
}

// KeyStore_SubscribeToKeyChanges_Call is a *mock.Call that shadows Run/Return methods with type explicit version for method 'SubscribeToKeyChanges'
type KeyStore_SubscribeToKeyChanges_Call[ADDR types.Hashable, CHAIN_ID types.ID, SEQ types.Sequence] struct {
	*mock.Call
}

// SubscribeToKeyChanges is a helper method to define mock.On call
//   - ctx context.Context
func (_e *KeyStore_Expecter[ADDR, CHAIN_ID, SEQ]) SubscribeToKeyChanges(ctx interface{}) *KeyStore_SubscribeToKeyChanges_Call[ADDR, CHAIN_ID, SEQ] {
	return &KeyStore_SubscribeToKeyChanges_Call[ADDR, CHAIN_ID, SEQ]{Call: _e.mock.On("SubscribeToKeyChanges", ctx)}
}

func (_c *KeyStore_SubscribeToKeyChanges_Call[ADDR, CHAIN_ID, SEQ]) Run(run func(ctx context.Context)) *KeyStore_SubscribeToKeyChanges_Call[ADDR, CHAIN_ID, SEQ] {
	_c.Call.Run(func(args mock.Arguments) {
		run(args[0].(context.Context))
	})
	return _c
}

func (_c *KeyStore_SubscribeToKeyChanges_Call[ADDR, CHAIN_ID, SEQ]) Return(ch chan struct{}, unsub func()) *KeyStore_SubscribeToKeyChanges_Call[ADDR, CHAIN_ID, SEQ] {
	_c.Call.Return(ch, unsub)
	return _c
}

func (_c *KeyStore_SubscribeToKeyChanges_Call[ADDR, CHAIN_ID, SEQ]) RunAndReturn(run func(context.Context) (chan struct{}, func())) *KeyStore_SubscribeToKeyChanges_Call[ADDR, CHAIN_ID, SEQ] {
	_c.Call.Return(run)
	return _c
}

// NewKeyStore creates a new instance of KeyStore. It also registers a testing interface on the mock and a cleanup function to assert the mocks expectations.
// The first argument is typically a *testing.T value.
func NewKeyStore[ADDR types.Hashable, CHAIN_ID types.ID, SEQ types.Sequence](t interface {
	mock.TestingT
	Cleanup(func())
}) *KeyStore[ADDR, CHAIN_ID, SEQ] {
	mock := &KeyStore[ADDR, CHAIN_ID, SEQ]{}
	mock.Mock.Test(t)

	t.Cleanup(func() { mock.AssertExpectations(t) })

	return mock
}