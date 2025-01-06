import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { organizationService } from '@/services/organization'

export const useOrganizationStore = defineStore('organization', () => {
  const orgTree = ref([])
  const currentOrg = ref(null)
  const loading = ref(false)
  const error = ref(null)

  const fetchOrgTree = async () => {
    loading.value = true
    error.value = null
    try {
      orgTree.value = await organizationService.getOrgTree()
    } catch (e) {
      error.value = e.message
      throw e
    } finally {
      loading.value = false
    }
  }

  const setCurrentOrg = (org) => {
    currentOrg.value = org
  }

  const updateOrg = async (id, updates) => {
    await organizationService.updateOrg(id, updates)
    await fetchOrgTree()
  }

  const deleteOrg = async (id) => {
    await organizationService.deleteOrg(id)
    await fetchOrgTree()
  }

  return {
    orgTree,
    currentOrg,
    loading,
    error,
    fetchOrgTree,
    setCurrentOrg,
    updateOrg,
    deleteOrg
  }
}) 