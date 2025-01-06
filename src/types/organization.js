/**
 * @typedef {import('./database').Organization} Organization
 */

/**
 * @typedef {Object} OrganizationTree
 * @property {string} id
 * @property {string} name
 * @property {string} [code]
 * @property {import('./database').OrgType} org_type
 * @property {string} [parent_id]
 * @property {string} [path]
 * @property {number} [level_num]
 * @property {number} [sort_order]
 * @property {string} [description]
 * @property {import('./database').StatusType} status
 * @property {string} created_at
 * @property {string} updated_at
 * @property {string} [created_by]
 * @property {string} [updated_by]
 * @property {OrganizationTree[]} children
 */

/**
 * @typedef {Object} OrgQueryParams
 * @property {string} [parentId]
 * @property {import('./database').OrgType} [orgType]
 * @property {import('./database').StatusType} [status]
 * @property {string} [keyword]
 */

/**
 * @typedef {Object} OrgMoveParams
 * @property {string} id
 * @property {string} targetId
 * @property {'before' | 'after' | 'inner'} position
 */

export const MOVE_POSITIONS = {
  BEFORE: 'before',
  AFTER: 'after',
  INNER: 'inner'
} 