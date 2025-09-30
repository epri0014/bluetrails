// Creates a standardized HTTP response
export const createResponse = (data, status = 200, headers = {}) => {
  const defaultHeaders = {
    'Content-Type': 'application/json',
    ...headers,
  };

  return new Response(JSON.stringify(data), {
    status,
    headers: defaultHeaders,
  });
};

// Creates a standardized error response
export const createErrorResponse = (message, status = 400, code = null) => {
  return createResponse({
    error: {
      message,
      code,
      status,
    },
  }, status);
};

// Creates a standardized success response
export const createSuccessResponse = (data, message = null) => {
  return createResponse({
    success: true,
    message,
    data,
  });
};