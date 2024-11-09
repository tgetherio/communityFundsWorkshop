// Code generated by mockery v2.43.2. DO NOT EDIT.

package mocks

import (
	context "context"

	network "github.com/smartcontractkit/chainlink/v2/core/services/gateway/network"
	mock "github.com/stretchr/testify/mock"
)

// HTTPClient is an autogenerated mock type for the HTTPClient type
type HTTPClient struct {
	mock.Mock
}

type HTTPClient_Expecter struct {
	mock *mock.Mock
}

func (_m *HTTPClient) EXPECT() *HTTPClient_Expecter {
	return &HTTPClient_Expecter{mock: &_m.Mock}
}

// Send provides a mock function with given fields: ctx, req
func (_m *HTTPClient) Send(ctx context.Context, req network.HTTPRequest) (*network.HTTPResponse, error) {
	ret := _m.Called(ctx, req)

	if len(ret) == 0 {
		panic("no return value specified for Send")
	}

	var r0 *network.HTTPResponse
	var r1 error
	if rf, ok := ret.Get(0).(func(context.Context, network.HTTPRequest) (*network.HTTPResponse, error)); ok {
		return rf(ctx, req)
	}
	if rf, ok := ret.Get(0).(func(context.Context, network.HTTPRequest) *network.HTTPResponse); ok {
		r0 = rf(ctx, req)
	} else {
		if ret.Get(0) != nil {
			r0 = ret.Get(0).(*network.HTTPResponse)
		}
	}

	if rf, ok := ret.Get(1).(func(context.Context, network.HTTPRequest) error); ok {
		r1 = rf(ctx, req)
	} else {
		r1 = ret.Error(1)
	}

	return r0, r1
}

// HTTPClient_Send_Call is a *mock.Call that shadows Run/Return methods with type explicit version for method 'Send'
type HTTPClient_Send_Call struct {
	*mock.Call
}

// Send is a helper method to define mock.On call
//   - ctx context.Context
//   - req network.HTTPRequest
func (_e *HTTPClient_Expecter) Send(ctx interface{}, req interface{}) *HTTPClient_Send_Call {
	return &HTTPClient_Send_Call{Call: _e.mock.On("Send", ctx, req)}
}

func (_c *HTTPClient_Send_Call) Run(run func(ctx context.Context, req network.HTTPRequest)) *HTTPClient_Send_Call {
	_c.Call.Run(func(args mock.Arguments) {
		run(args[0].(context.Context), args[1].(network.HTTPRequest))
	})
	return _c
}

func (_c *HTTPClient_Send_Call) Return(_a0 *network.HTTPResponse, _a1 error) *HTTPClient_Send_Call {
	_c.Call.Return(_a0, _a1)
	return _c
}

func (_c *HTTPClient_Send_Call) RunAndReturn(run func(context.Context, network.HTTPRequest) (*network.HTTPResponse, error)) *HTTPClient_Send_Call {
	_c.Call.Return(run)
	return _c
}

// NewHTTPClient creates a new instance of HTTPClient. It also registers a testing interface on the mock and a cleanup function to assert the mocks expectations.
// The first argument is typically a *testing.T value.
func NewHTTPClient(t interface {
	mock.TestingT
	Cleanup(func())
}) *HTTPClient {
	mock := &HTTPClient{}
	mock.Mock.Test(t)

	t.Cleanup(func() { mock.AssertExpectations(t) })

	return mock
}
