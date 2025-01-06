/**
 * @typedef {Object} ApiResponse
 * @property {*} [data] - 响应数据
 * @property {string} [error] - 错误信息
 * @property {string} [message] - 提示消息
 */

/**
 * @typedef {Object} PaginationParams
 * @property {number} page - 当前页码
 * @property {number} pageSize - 每页条数
 * @property {string} [sortBy] - 排序字段
 * @property {boolean} [sortDesc] - 是否降序
 */

/**
 * @typedef {Object} PaginatedResponse
 * @property {Array} items - 数据列表
 * @property {number} total - 总记录数
 * @property {number} page - 当前页码
 * @property {number} pageSize - 每页条数
 * @property {number} totalPages - 总页数
 */

export const STATUS_TYPES = {
  ACTIVE: 'active',
  INACTIVE: 'inactive',
  DELETED: 'deleted'
} 