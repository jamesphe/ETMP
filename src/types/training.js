/**
 * @typedef {Object} TrainingBase
 * @property {string} id
 * @property {string} base_code
 * @property {string} base_name
 * @property {string} dept_code
 * @property {string} dept_name
 * @property {string} establish_date
 * @property {string} support_unit
 * @property {string[]} major_names
 * @property {string[]} partner_companies
 * @property {'internal' | 'external'} base_type
 * @property {string} contact_person
 * @property {string} contact_phone
 * @property {string} [remarks]
 * @property {string} created_at
 * @property {string} updated_at
 * @property {string} [created_by]
 * @property {string} [updated_by]
 */

/**
 * @typedef {Object} TrainingRoom
 * @property {string} id
 * @property {string} room_code
 * @property {string} room_name
 * @property {string} base_id
 * @property {number} capacity
 * @property {string} equipment_info
 * @property {import('./database').StatusType} status
 * @property {string} created_at
 * @property {string} updated_at
 */

/**
 * @typedef {Object} TrainingQueryParams
 * @property {string} [orgId]
 * @property {string} [baseId]
 * @property {import('./database').StatusType} [status]
 * @property {string} [keyword]
 */

export const BASE_TYPES = {
  INTERNAL: 'internal',
  EXTERNAL: 'external'
} 