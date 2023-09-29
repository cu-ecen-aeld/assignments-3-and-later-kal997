#include "threading.h"
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

// Optional: use these functions to add debug or error prints to your application
#define DEBUG_LOG(msg,...)
//#define DEBUG_LOG(msg,...) printf("threading: " msg "\n" , ##__VA_ARGS__)
#define ERROR_LOG(msg,...) printf("threading ERROR: " msg "\n" , ##__VA_ARGS__)

void* threadfunc(void* thread_param)
{

    // TODO: wait, obtain mutex, wait, release mutex as described by thread_data structure
    // hint: use a cast like the one below to obtain thread arguments from your parameter
    printf("$$$$ threadfunc is called $$$\n");
    struct thread_data* thread_func_args = (struct thread_data *) thread_param;
    printf("thread_func_args->m_wait_to_obtain_ms = %d\n", thread_func_args->m_wait_to_obtain_ms);
    usleep(1000*thread_func_args->m_wait_to_obtain_ms);
    printf("done with 1st sleeping\n");
    int rc_lock = pthread_mutex_lock(thread_func_args->m_pmutexToBeAquired);
    if(rc_lock != 0)
    {
        printf("cannot obtain mutex\n");
        thread_func_args->thread_complete_success = false;
    }
    else
    {
        printf("locking done successfully\n");
        usleep(1000*thread_func_args->m_wait_to_release_ms);
        int rc_unlock = pthread_mutex_unlock(thread_func_args->m_pmutexToBeAquired);
        if(rc_unlock != 0)
        {
            printf("cannot unlock obtained mutex\n");
            thread_func_args->thread_complete_success = false;

        }
        else
        {
            printf("unlocking done successfully\n");
            thread_func_args->thread_complete_success = true;
        }
    }

    return thread_param;
}

bool start_thread_obtaining_mutex(pthread_t *thread, pthread_mutex_t *mutex,int wait_to_obtain_ms, int wait_to_release_ms)
{
    bool retVal;
    struct thread_data* pthreadData = malloc(sizeof(struct thread_data));
    
    pthreadData->m_wait_to_release_ms = wait_to_release_ms;
    pthreadData->m_wait_to_obtain_ms = wait_to_obtain_ms;
    pthreadData->m_pmutexToBeAquired = mutex;
    printf("start_thread_obtaining_mutex : 1 = %d\n", pthreadData->m_wait_to_release_ms);
    printf("start_thread_obtaining_mutex : 2 = %d\n", pthreadData->m_wait_to_obtain_ms);
    

    int rc = pthread_create(thread , NULL, threadfunc, (void*)pthreadData);
    if(rc != 0)
    {
        printf("thread did not created successfully\n");
        retVal = false;
    }
    else
    {
        printf("thread created successfully\n");
        retVal = true;
    }

    

    /**
     * TODO: allocate memory for thread_data, setup mutex and wait arguments, pass thread_data to created thread
     * using threadfunc() as entry point.
     *
     * return true if successful.
     *
     * See implementation details in threading.h file comment block
     */
    return retVal;
}

