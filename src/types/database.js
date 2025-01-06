/**
 * @typedef {'active' | 'inactive' | 'deleted'} StatusType
 */

/**
 * @typedef {'school' | 'party' | 'administrative' | 'academic' | 'teaching' | 'research' | 'service' | 'project' | 'temporary' | 'other'} OrgType
 */

/**
 * @typedef {Object} Organization
 * @property {string} id
 * @property {string} name
 * @property {string} [code]
 * @property {OrgType} org_type
 * @property {string} [parent_id]
 * @property {string} [path]
 * @property {number} [level_num]
 * @property {number} [sort_order]
 * @property {string} [description]
 * @property {StatusType} status
 * @property {string} created_at
 * @property {string} updated_at
 * @property {string} [created_by]
 * @property {string} [updated_by]
 */

export const ORG_TYPES = {
  SCHOOL: 'school',
  PARTY: 'party',
  ADMINISTRATIVE: 'administrative',
  ACADEMIC: 'academic',
  TEACHING: 'teaching',
  RESEARCH: 'research',
  SERVICE: 'service',
  PROJECT: 'project',
  TEMPORARY: 'temporary',
  OTHER: 'other'
}

export const STATUS_TYPES = {
  ACTIVE: 'active',
  INACTIVE: 'inactive',
  DELETED: 'deleted'
} 